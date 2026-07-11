import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Hỗ trợ tương thích ngược với code cũ.
typedef Challenge = ChallengeModel;

/// Trạng thái vòng đời của một Thách đấu (Self-Gambling).
enum ChallengeStatus {
  /// Thử thách đã được lên lịch nhưng chưa đến ngày bắt đầu.
  pending,

  /// Thử thách đang diễn ra và đang theo dõi chi tiêu.
  active,

  /// Thử thách hoàn thành thành công (không vượt hạn mức chi tiêu).
  completed,

  /// Thử thách thất bại (vượt quá hạn mức chi tiêu).
  failed,

  /// Người dùng tự hủy/bỏ cuộc giữa chừng.
  forfeited;

  /// Chuyển enum sang String để lưu SQLite.
  String toJson() => name;

  /// Phục hồi enum từ String SQLite.
  static ChallengeStatus fromJson(String name) {
    return ChallengeStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ChallengeStatus.active,
    );
  }
}

/// {@template challenge}
/// Đại diện cho một cuộc Thách Đấu Với Chính Mình (Self-Gambling Mode).
/// 
/// Lưu trữ cấu hình luật chơi (hạn mức, số tiền cược), thời gian diễn ra,
/// các danh mục áp dụng và cập nhật tiến trình thực tế.
/// {@endtemplate}
@immutable
class ChallengeModel extends Equatable {
  /// Mã định danh duy nhất của cuộc thách đấu.
  final String id;

  /// Mã định danh người dùng sở hữu thử thách.
  final String userId;

  /// Ví được áp dụng để theo dõi và tổng hợp chi tiêu thực tế.
  final String walletId;

  /// Tiêu đề của cuộc thách đấu.
  final String title;

  /// Mô tả chi tiết hoặc ghi chú.
  final String description;

  /// Biểu tượng cảm xúc hiển thị của thử thách (tương thích cũ).
  final String icon;

  /// Hạn mức chi tiêu tối đa được phép trong suốt thời gian diễn ra.
  final double spendLimit;

  /// Số tiền đặt cược bị đóng băng trong ví.
  final double betAmount;

  /// Ngày bắt đầu theo dõi chi tiêu.
  final DateTime startDate;

  /// Ngày kết thúc (hạn chốt) thách đấu.
  final DateTime endDate;

  /// Trạng thái hiện tại của thách đấu.
  final ChallengeStatus status;

  /// Tổng số tiền thực tế đã chi tiêu.
  final double actualSpent;

  /// Danh sách các ID danh mục (Category) bị giới hạn chi tiêu.
  final List<String> categoryIds;

  /// Chuỗi ngày kỷ luật hiện tại.
  final int currentStreak;

  /// Số lượng khiên cứu mạng còn lại.
  final int shields;

  /// Số lần vi phạm tối đa cho phép.
  final int maxViolations;

  /// Số lần vi phạm hiện tại.
  final int currentViolations;

  /// Thử thách có phải là chế độ đấu đối kháng AI không.
  final bool isAiDuel;

  /// Số tiền đối thủ AI đã chi tiêu.
  final double aiSpent;

  /// Lịch sử chi tiêu theo các ngày.
  final List<double> dailySpending;

  /// {@macro challenge}
  ChallengeModel({
    required this.id,
    this.userId = 'user123',
    this.walletId = 'w1',
    required this.title,
    String? description,
    this.icon = '🥗', // Mặc định để tương thích cũ
    double? spendLimit,
    double? targetAmount, // Tương thích cũ
    double? betAmount,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? deadline, // Tương thích cũ
    ChallengeStatus? status,
    bool? isCompleted, // Tương thích cũ
    double? actualSpent,
    double? savedAmount, // Tương thích cũ
    this.categoryIds = const [],
    this.currentStreak = 0,
    this.shields = 0,
    this.maxViolations = 1,
    this.currentViolations = 0,
    this.isAiDuel = false,
    this.aiSpent = 0.0,
    this.dailySpending = const [],
  })  : description = description ?? '',
        spendLimit = spendLimit ?? targetAmount ?? 0.0,
        betAmount = betAmount ?? 0.0,
        startDate = startDate ?? DateTime.fromMillisecondsSinceEpoch(0),
        endDate = endDate ?? deadline ?? DateTime.fromMillisecondsSinceEpoch(0),
        status = status ?? ((isCompleted ?? false) ? ChallengeStatus.completed : ChallengeStatus.active),
        actualSpent = actualSpent ?? savedAmount ?? 0.0;

  /// Tương thích cũ: ánh xạ ngược lại các getter
  double get targetAmount => spendLimit;
  double get savedAmount => actualSpent;
  DateTime get deadline => endDate;
  bool get isCompleted => status == ChallengeStatus.completed;

  /// Tính toán phần trăm chi tiêu hiện tại so với hạn mức (từ 0.0 đến 1.0+).
  double get progress => spendLimit > 0 ? (actualSpent / spendLimit) : 0.0;

  /// Tính số ngày còn lại cho đến khi hết hạn.
  int get daysLeft {
    final difference = endDate.difference(DateTime.now()).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Cho biết thử thách này vẫn còn khả năng thực hiện hay đã kết thúc.
  bool get isEnded => 
      status == ChallengeStatus.completed || 
      status == ChallengeStatus.failed || 
      status == ChallengeStatus.forfeited;

  /// Tạo một bản sao mới của [ChallengeModel] nhưng thay đổi một vài thuộc tính.
  ChallengeModel copyWith({
    String? id,
    String? userId,
    String? walletId,
    String? title,
    String? description,
    String? icon,
    double? spendLimit,
    double? betAmount,
    DateTime? startDate,
    DateTime? endDate,
    ChallengeStatus? status,
    double? actualSpent,
    List<String>? categoryIds,
    int? currentStreak,
    int? shields,
    int? maxViolations,
    int? currentViolations,
    bool? isAiDuel,
    double? aiSpent,
    List<double>? dailySpending,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletId: walletId ?? this.walletId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      spendLimit: spendLimit ?? this.spendLimit,
      betAmount: betAmount ?? this.betAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      actualSpent: actualSpent ?? this.actualSpent,
      categoryIds: categoryIds ?? this.categoryIds,
      currentStreak: currentStreak ?? this.currentStreak,
      shields: shields ?? this.shields,
      maxViolations: maxViolations ?? this.maxViolations,
      currentViolations: currentViolations ?? this.currentViolations,
      isAiDuel: isAiDuel ?? this.isAiDuel,
      aiSpent: aiSpent ?? this.aiSpent,
      dailySpending: dailySpending ?? this.dailySpending,
    );
  }

  /// Chuyển đổi đối tượng [ChallengeModel] sang dạng Map để lưu vào database SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'wallet_id': walletId,
      'title': title,
      'description': description,
      'icon': icon,
      'spend_limit': spendLimit,
      'bet_amount': betAmount,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate.millisecondsSinceEpoch,
      'status': status.toJson(),
      'actual_spent': actualSpent,
      'category_ids': json.encode(categoryIds),
      'current_streak': currentStreak,
      'shields': shields,
      'max_violations': maxViolations,
      'current_violations': currentViolations,
      'is_ai_duel': isAiDuel ? 1 : 0,
      'ai_spent': aiSpent,
      'daily_spending': json.encode(dailySpending),
    };
  }

  /// Khởi tạo đối tượng [ChallengeModel] từ dữ liệu Map lấy từ database SQLite.
  factory ChallengeModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedCategoryIds = [];
    if (map['category_ids'] != null) {
      try {
        final decoded = json.decode(map['category_ids'] as String);
        parsedCategoryIds = List<String>.from(decoded as List);
      } catch (_) {
        parsedCategoryIds = [];
      }
    }

    List<double> parsedDailySpending = [];
    if (map['daily_spending'] != null) {
      try {
        final decoded = json.decode(map['daily_spending'] as String);
        parsedDailySpending = List<double>.from((decoded as List).map((x) => (x as num).toDouble()));
      } catch (_) {
        parsedDailySpending = [];
      }
    }

    return ChallengeModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? 'user123',
      walletId: map['wallet_id'] as String? ?? 'w1',
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String? ?? '🥗',
      spendLimit: (map['spend_limit'] as num? ?? 0.0).toDouble(),
      betAmount: (map['bet_amount'] as num? ?? 0.0).toDouble(),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int? ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int? ?? 0),
      status: ChallengeStatus.fromJson(map['status'] as String? ?? 'active'),
      actualSpent: (map['actual_spent'] as num? ?? 0.0).toDouble(),
      categoryIds: parsedCategoryIds,
      currentStreak: map['current_streak'] as int? ?? 0,
      shields: map['shields'] as int? ?? 0,
      maxViolations: map['max_violations'] as int? ?? 1,
      currentViolations: map['current_violations'] as int? ?? 0,
      isAiDuel: (map['is_ai_duel'] as int? ?? 0) == 1,
      aiSpent: (map['ai_spent'] as num? ?? 0.0).toDouble(),
      dailySpending: parsedDailySpending,
    );
  }

  /// Chuyển đổi đối tượng [ChallengeModel] sang chuỗi JSON.
  String toJson() => json.encode(toMap());

  /// Khởi tạo đối tượng [ChallengeModel] từ chuỗi JSON.
  factory ChallengeModel.fromJson(String source) => 
      ChallengeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
        id,
        userId,
        walletId,
        title,
        description,
        icon,
        spendLimit,
        betAmount,
        startDate,
        endDate,
        status,
        actualSpent,
        categoryIds,
        currentStreak,
        shields,
        maxViolations,
        currentViolations,
        isAiDuel,
        aiSpent,
        dailySpending,
      ];
}
