import '../models/challenge_model.dart';

class ChallengeController {
  // Giả lập dữ liệu thử thách hiện tại (trong thực tế sẽ lấy từ database)
  ChallengeModel? activeChallenge;

  void createChallenge(String title, double target, double frozen) {
    activeChallenge = ChallengeModel(
      id: DateTime.now().toString(),
      title: title,
      targetAmount: target,
      frozenAmount: frozen,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)), // Thách đấu 1 tuần
    );
  }

  void updateExpense(double amount) {
    if (activeChallenge != null && activeChallenge!.status == ChallengeStatus.ongoing) {
      activeChallenge!.currentSpent += amount;

      // Kiểm tra trạng thái
      if (activeChallenge!.currentSpent > activeChallenge!.targetAmount) {
        activeChallenge!.status = ChallengeStatus.failed;
      }
    }
  }
}