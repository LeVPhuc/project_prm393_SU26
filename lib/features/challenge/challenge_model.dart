class ChallengeModel {

  int? id;

  String title;

  double targetAmount;

  double currentAmount;

  double freezeMoney;

  DateTime startDate;

  DateTime endDate;

  bool isCompleted;

  bool isFailed;

  ChallengeModel({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.freezeMoney,
    required this.startDate,
    required this.endDate,
    required this.isCompleted,
    required this.isFailed,
  });
}