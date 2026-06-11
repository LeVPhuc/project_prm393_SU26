enum ChallengeStatus { ongoing, success, failed }

class ChallengeModel {
  final String id;
  final String title;
  final double targetAmount;   // Ngân sách mục tiêu
  final double frozenAmount;   // Số tiền đóng băng
  double currentSpent;         // Số tiền đã tiêu
  final DateTime startDate;
  final DateTime endDate;
  ChallengeStatus status;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.frozenAmount,
    this.currentSpent = 0.0,
    required this.startDate,
    required this.endDate,
    this.status = ChallengeStatus.ongoing,
  });

  // Tính phần trăm tiến độ để hiển thị thanh progress bar
  double get progress => (currentSpent / targetAmount).clamp(0.0, 1.0);

  // Kiểm tra xem đã thất bại chưa
  bool get isFailed => currentSpent > targetAmount;
}