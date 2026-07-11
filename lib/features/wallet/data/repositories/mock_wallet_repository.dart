import '../../../../models/wallet_model.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Bản hiện thực Mock của WalletRepository sử dụng bộ nhớ RAM (In-Memory).
class MockWalletRepository implements WalletRepository {
  final List<WalletModel> _wallets = [
    WalletModel(
      id: 'w1',
      userId: 'user123',
      name: 'Ví Tiền Một',
      balance: 2450000.0,
      frozenBalance: 0.0,
      currency: 'VND',
      icon: '💵',
      colorIndex: 0,
      type: 'cash',
      isDefault: true,
      updatedAt: DateTime.now(),
    ),
    WalletModel(
      id: 'w2',
      userId: 'user123',
      name: 'Vietcombank',
      balance: 15780000.0,
      frozenBalance: 0.0,
      currency: 'VND',
      icon: '🏦',
      colorIndex: 1,
      type: 'bank',
      isDefault: false,
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<WalletModel>> getWallets() async {
    return _wallets;
  }

  @override
  Future<WalletModel?> getWalletById(String id) async {
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateBalance(String id, double newBalance) async {
    final index = _wallets.indexWhere((w) => w.id == id);
    if (index != -1) {
      _wallets[index] = _wallets[index].copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> freezeAmount(String id, double amount) async {
    final index = _wallets.indexWhere((w) => w.id == id);
    if (index != -1) {
      final updatedFrozen = _wallets[index].frozenBalance + amount;
      _wallets[index] = _wallets[index].copyWith(
        frozenBalance: updatedFrozen,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> unfreezeAmount(String id, double amount) async {
    final index = _wallets.indexWhere((w) => w.id == id);
    if (index != -1) {
      final updatedFrozen = _wallets[index].frozenBalance - amount;
      _wallets[index] = _wallets[index].copyWith(
        frozenBalance: updatedFrozen < 0 ? 0 : updatedFrozen,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> creditWallet(String id, double amount) async {
    final index = _wallets.indexWhere((w) => w.id == id);
    if (index != -1) {
      final updatedBalance = _wallets[index].balance + amount;
      _wallets[index] = _wallets[index].copyWith(
        balance: updatedBalance,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> debitWallet(String id, double amount) async {
    final index = _wallets.indexWhere((w) => w.id == id);
    if (index != -1) {
      final updatedBalance = _wallets[index].balance - amount;
      _wallets[index] = _wallets[index].copyWith(
        balance: updatedBalance < 0 ? 0 : updatedBalance,
        updatedAt: DateTime.now(),
      );
    }
  }
}
