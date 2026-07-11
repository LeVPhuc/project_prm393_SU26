import '../../../../models/challenge_model.dart';
import '../../domain/repositories/challenge_repository.dart';

/// Bản hiện thực Mock của ChallengeRepository sử dụng bộ nhớ RAM.
class MockChallengeRepository implements ChallengeRepository {
  final List<ChallengeModel> _challenges = [
    ChallengeModel(
      id: 'c1',
      userId: 'user123',
      walletId: 'w1',
      title: 'Hạn chế mua sắm tuần này 🛍️',
      description: 'Quyết tâm không shopping quần áo linh tinh',
      spendLimit: 500000.0,
      betAmount: 100000.0,
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      status: ChallengeStatus.active,
      actualSpent: 120000.0,
      categoryIds: const ['cat_shopping'],
    ),
  ];

  @override
  Future<List<ChallengeModel>> getChallenges() async {
    return _challenges;
  }

  @override
  Future<ChallengeModel?> getChallengeById(String id) async {
    try {
      return _challenges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createChallenge(ChallengeModel challenge) async {
    _challenges.add(challenge);
  }

  @override
  Future<void> updateChallenge(ChallengeModel challenge) async {
    final index = _challenges.indexWhere((c) => c.id == challenge.id);
    if (index != -1) {
      _challenges[index] = challenge;
    }
  }

  @override
  Future<void> deleteChallenge(String id) async {
    _challenges.removeWhere((c) => c.id == id);
  }
}
