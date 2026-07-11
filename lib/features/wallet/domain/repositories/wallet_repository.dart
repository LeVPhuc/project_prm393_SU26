import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../models/wallet_model.dart';

part 'wallet_repository.g.dart';

/// Giao diện định nghĩa các thao tác dữ liệu ví tài chính.
abstract class WalletRepository {
  /// Lấy danh sách tất cả các ví.
  Future<List<WalletModel>> getWallets();

  /// Lấy chi tiết ví theo ID.
  Future<WalletModel?> getWalletById(String id);

  /// Cập nhật số dư của ví.
  Future<void> updateBalance(String id, double newBalance);

  /// Đóng băng một khoản tiền trong ví.
  /// 
  /// Tăng `frozenBalance` lên thêm một lượng [amount].
  Future<void> freezeAmount(String id, double amount);

  /// Giải tỏa một khoản tiền đang bị đóng băng.
  /// 
  /// Giảm `frozenBalance` đi một lượng [amount].
  Future<void> unfreezeAmount(String id, double amount);

  /// Ghi có số dư (cộng tiền thưởng hoặc hoàn trả tiền cược).
  Future<void> creditWallet(String id, double amount);

  /// Ghi nợ số dư (trừ tiền thực tế khi thua cược).
  Future<void> debitWallet(String id, double amount);
}

// Khởi tạo provider mặc định (sẽ được override bằng mock hoặc sqlite repo trong app.dart)
@riverpod
WalletRepository walletRepository(WalletRepositoryRef ref) {
  throw UnimplementedError('walletRepositoryProvider has not been overridden');
}
