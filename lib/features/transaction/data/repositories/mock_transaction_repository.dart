import '../../../../models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';

/// Bản hiện thực Mock của TransactionRepository sử dụng bộ nhớ RAM.
class MockTransactionRepository implements TransactionRepository {
  final List<TransactionModel> _transactions = [];

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<List<TransactionModel>> getTransactionsByWallet(String walletId) async {
    return _transactions.where((t) => t.walletId == walletId).toList();
  }

  @override
  Future<List<TransactionModel>> getTransactionsByChallenge(String challengeId) async {
    return _transactions.where((t) => t.challengeId == challengeId).toList();
  }
}
