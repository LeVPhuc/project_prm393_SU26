import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../models/transaction_model.dart';

part 'transaction_repository.g.dart';

/// Giao diện định nghĩa các thao tác dữ liệu liên quan đến Giao dịch.
abstract class TransactionRepository {
  /// Thêm mới một giao dịch.
  Future<void> addTransaction(TransactionModel transaction);

  /// Lấy danh sách giao dịch của một ví.
  Future<List<TransactionModel>> getTransactionsByWallet(String walletId);

  /// Lấy danh sách các giao dịch thuộc về một cuộc thách đấu cụ thể.
  Future<List<TransactionModel>> getTransactionsByChallenge(String challengeId);
}

// Khởi tạo provider mặc định
@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  throw UnimplementedError('transactionRepositoryProvider has not been overridden');
}
