class ChallengeModel {
  final int id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final double freezeMoney;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.freezeMoney,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  ChallengeModel copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    double? freezeMoney,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      freezeMoney: freezeMoney ?? this.freezeMoney,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }
}