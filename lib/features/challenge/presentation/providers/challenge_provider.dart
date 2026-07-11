import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../models/challenge_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../domain/repositories/challenge_repository.dart';

part 'challenge_provider.g.dart';

/// Notifier quản lý danh sách Thách đấu trong hệ thống.
/// 
/// Hỗ trợ nạp dữ liệu bất đồng bộ và cung cấp các hàm nghiệp vụ:
/// tạo cược, cập nhật chi tiêu, giải tỏa cược khi hoàn thành/thất bại.
@riverpod
class ChallengeListNotifier extends _$ChallengeListNotifier {
  @override
  FutureOr<List<ChallengeModel>> build() async {
    final repository = ref.watch(challengeRepositoryProvider);
    return repository.getChallenges();
  }

  /// Tạo một Thách đấu mới (Self-Gambling) và thực hiện đóng băng tiền cược.
  Future<void> createChallenge({
    required String title,
    String? description,
    required String walletId,
    required double spendLimit,
    required double betAmount,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> categoryIds,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final challengeRepo = ref.read(challengeRepositoryProvider);
      final walletRepo = ref.read(walletRepositoryProvider);

      // 1. Kiểm tra số dư ví khả dụng trước khi cược
      final wallet = await walletRepo.getWalletById(walletId);
      if (wallet == null) {
        throw Exception('Không tìm thấy ví đã chọn.');
      }
      if (wallet.availableBalance < betAmount) {
        throw Exception('Số dư khả dụng của ví không đủ để thực hiện đặt cược.');
      }

      // 2. Tạo đối tượng ChallengeModel mới
      final challengeId = DateTime.now().millisecondsSinceEpoch.toString(); // Có thể dùng UUID
      final newChallenge = ChallengeModel(
        id: challengeId,
        userId: wallet.userId,
        walletId: walletId,
        title: title,
        description: description,
        spendLimit: spendLimit,
        betAmount: betAmount,
        startDate: startDate,
        endDate: endDate,
        status: ChallengeStatus.active, // Mặc định kích hoạt ngay
        actualSpent: 0.0,
        categoryIds: categoryIds,
      );

      // 3. Thực hiện đóng băng tiền trong ví (Atomic Transaction ở tầng DB)
      await walletRepo.freezeAmount(walletId, betAmount);

      // 4. Lưu Thách đấu vào SQLite
      await challengeRepo.createChallenge(newChallenge);

      // 5. Trả về danh sách thử thách cập nhật mới nhất
      return challengeRepo.getChallenges();
    });
  }

  /// Ghi nhận giao dịch chi tiêu mới và cập nhật tiến trình thử thách liên quan.
  Future<void> addExpenseToChallenge({
    required String challengeId,
    required String title,
    required double amount,
    required String categoryId,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final challengeRepo = ref.read(challengeRepositoryProvider);
      final txnRepo = ref.read(transactionRepositoryProvider);

      final challenge = await challengeRepo.getChallengeById(challengeId);
      if (challenge == null) {
        throw Exception('Không tìm thấy cuộc thách đấu.');
      }

      if (challenge.isEnded) {
        throw Exception('Thách đấu đã kết thúc, không thể thêm chi tiêu.');
      }

      // 1. Lưu giao dịch chi tiêu vào DB
      final txnId = DateTime.now().millisecondsSinceEpoch.toString();
      final newTxn = TransactionModel(
        id: txnId,
        walletId: challenge.walletId,
        categoryId: categoryId,
        challengeId: challengeId,
        amount: amount,
        type: TransactionType.expense,
        title: title,
        date: date,
        createdAt: DateTime.now(),
      );
      await txnRepo.addTransaction(newTxn);

      // 2. Cập nhật tổng chi tiêu (actualSpent) của thử thách
      final updatedActualSpent = challenge.actualSpent + amount;
      final updatedChallenge = challenge.copyWith(actualSpent: updatedActualSpent);
      await challengeRepo.updateChallenge(updatedChallenge);

      // 3. Tự động kiểm tra trạng thái ngay sau khi cập nhật chi tiêu (Auto-Fail check)
      await _checkAndEvaluateStatus(updatedChallenge);

      return challengeRepo.getChallenges();
    });
  }

  /// Hoàn thành thách đấu thành công: Giải tỏa tiền cược và cộng thưởng kỷ luật.
  Future<void> completeChallenge(String challengeId, {double rewardBonus = 0.0}) async {
    final challengeRepo = ref.read(challengeRepositoryProvider);
    final walletRepo = ref.read(walletRepositoryProvider);

    final challenge = await challengeRepo.getChallengeById(challengeId);
    if (challenge == null || challenge.isEnded) return;

    // 1. Trả lại khoản đóng băng cược gốc về số dư khả dụng
    await walletRepo.unfreezeAmount(challenge.walletId, challenge.betAmount);

    // 2. Ghi nhận tiền thưởng (credit) nếu có vào số dư ví
    if (rewardBonus > 0) {
      await walletRepo.creditWallet(challenge.walletId, rewardBonus);
    }

    // 3. Cập nhật trạng thái thách đấu sang COMPLETED
    final completedChallenge = challenge.copyWith(status: ChallengeStatus.completed);
    await challengeRepo.updateChallenge(completedChallenge);
  }

  /// Thất bại thách đấu: Giải phóng đóng băng và trừ đứt số dư ví (mất tiền cược).
  Future<void> failChallenge(String challengeId) async {
    final challengeRepo = ref.read(challengeRepositoryProvider);
    final walletRepo = ref.read(walletRepositoryProvider);

    final challenge = await challengeRepo.getChallengeById(challengeId);
    if (challenge == null || challenge.isEnded) return;

    // 1. Giải phóng đóng băng (đưa frozenBalance về 0)
    await walletRepo.unfreezeAmount(challenge.walletId, challenge.betAmount);

    // 2. Khấu trừ trực tiếp số dư ví (debit) do thua cược
    await walletRepo.debitWallet(challenge.walletId, challenge.betAmount);

    // 3. Cập nhật trạng thái thách đấu sang FAILED
    final failedChallenge = challenge.copyWith(status: ChallengeStatus.failed);
    await challengeRepo.updateChallenge(failedChallenge);
  }

  /// Đánh giá thủ công hoặc định kỳ thời hạn của tất cả các thách đấu đang chạy.
  Future<void> checkAllChallengesStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final challengeRepo = ref.read(challengeRepositoryProvider);
      final list = await challengeRepo.getChallenges();
      
      for (final challenge in list) {
        if (challenge.status == ChallengeStatus.active) {
          await _checkAndEvaluateStatus(challenge);
        }
      }
      return challengeRepo.getChallenges();
    });
  }

  /// Helper check trạng thái của một Thách đấu cụ thể và kích hoạt kết quả.
  Future<void> _checkAndEvaluateStatus(ChallengeModel challenge) async {
    final now = DateTime.now();

    // Luật 1: Nếu thực tế chi tiêu đã vượt quá hạn mức -> Tự động THẤT BẠI ngay lập tức (Auto-Fail)
    if (challenge.actualSpent > challenge.spendLimit) {
      await failChallenge(challenge.id);
      return;
    }

    // Luật 2: Đến ngày kết thúc và chi tiêu vẫn nằm trong tầm kiểm soát -> Hoàn thành thành công (Auto-Complete)
    if (now.isAfter(challenge.endDate)) {
      // Tính toán tiền thưởng kỷ luật bằng 10% lượng tiền cược gốc làm gamification reward
      final bonusReward = challenge.betAmount * 0.10;
      await completeChallenge(challenge.id, rewardBonus: bonusReward);
    }
  }
}
