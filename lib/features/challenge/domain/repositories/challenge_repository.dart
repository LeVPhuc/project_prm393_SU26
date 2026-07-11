import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../models/challenge_model.dart';

part 'challenge_repository.g.dart';

/// Giao diện định nghĩa các thao tác dữ liệu của Thách Đấu.
abstract class ChallengeRepository {
  /// Lấy danh sách toàn bộ các thách đấu.
  Future<List<ChallengeModel>> getChallenges();

  /// Lấy chi tiết thách đấu theo ID.
  Future<ChallengeModel?> getChallengeById(String id);

  /// Tạo một thách đấu mới trong SQLite.
  Future<void> createChallenge(ChallengeModel challenge);

  /// Cập nhật thông tin chi tiết thách đấu (ví dụ: số tiền chi tiêu thực tế).
  Future<void> updateChallenge(ChallengeModel challenge);

  /// Xóa thách đấu khỏi hệ thống.
  Future<void> deleteChallenge(String id);
}

// Khởi tạo provider mặc định (sẽ được override khi cài đặt sqlite)
@riverpod
ChallengeRepository challengeRepository(ChallengeRepositoryRef ref) {
  throw UnimplementedError('challengeRepositoryProvider has not been overridden');
}
