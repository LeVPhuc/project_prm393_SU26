import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Hỗ trợ tương thích ngược với code cũ.
typedef Transaction = TransactionModel;

/// Phân loại chiều hướng của dòng tiền giao dịch.
enum TransactionType {
  /// Thu nhập (dòng tiền đi vào ví).
  income,

  /// Chi tiêu (dòng tiền đi ra khỏi ví).
  expense;

  /// Chuyển enum sang String để lưu SQLite.
  String toJson() => name;

  /// Phục hồi enum từ String SQLite.
  static TransactionType fromJson(String name) {
    return TransactionType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TransactionType.expense,
    );
  }
}

/// Danh mục phân loại cũ dùng để tương thích giao diện và dữ liệu mẫu.
enum TransactionCategory {
  food,
  transport,
  shopping,
  work,
  health,
  entertainment,
  other;

  /// Chuyển enum sang String.
  String toJson() => name;

  /// Phục hồi enum từ String.
  static TransactionCategory fromJson(String name) {
    return TransactionCategory.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TransactionCategory.other,
    );
  }
}

/// {@template transaction}
/// Đại diện cho một giao dịch Thu nhập hoặc Chi tiêu trong hệ thống Vún Vén.
/// 
/// Hỗ trợ liên kết với một ví cụ thể, một danh mục phân loại, và có thể
/// thuộc về một chiến dịch Thách đấu ([challengeId] khác null).
/// {@endtemplate}
@immutable
class TransactionModel extends Equatable {
  /// Mã định danh duy nhất của giao dịch (UUID v4).
  final String id;

  /// Mã định danh ví thực hiện giao dịch này.
  final String walletId;

  /// Mã định danh danh mục của giao dịch dạng chuỗi (dùng cho DB mới).
  final String categoryId;

  /// Danh mục dạng Enum (dùng để tương thích ngược với UI cũ).
  final TransactionCategory category;

  /// Mã định danh thử thách (nếu giao dịch này thuộc phạm vi theo dõi của Thách Đấu).
  final String? challengeId;

  /// Số tiền của giao dịch (luôn lớn hơn 0).
  final double amount;

  /// Chiều hướng thu hoặc chi của giao dịch.
  final TransactionType type;

  /// Tên hoặc tiêu đề tóm tắt của giao dịch (ví dụ: "Ăn trưa cơm văn phòng").
  final String title;

  /// Ghi chú chi tiết thêm của giao dịch.
  final String? note;

  /// Ngày phát sinh giao dịch do người dùng chọn.
  final DateTime date;

  /// Thời điểm bản ghi giao dịch được tạo ra trên hệ thống.
  final DateTime? createdAt;

  /// {@macro transaction}
  TransactionModel({
    required this.id,
    required this.walletId,
    String? categoryId,
    TransactionCategory? category, // Thêm để tương thích
    this.challengeId,
    required this.amount,
    required this.type,
    required this.title,
    this.note,
    required this.date,
    this.createdAt,
  })  : category = category ?? (type == TransactionType.income ? TransactionCategory.work : TransactionCategory.other),
        categoryId = categoryId ?? (category ?? (type == TransactionType.income ? TransactionCategory.work : TransactionCategory.other)).name;

  /// Tương thích ngược: Lấy nhãn tiếng Việt của danh mục.
  String get categoryLabel {
    switch (category) {
      case TransactionCategory.food:
        return 'Ăn uống';
      case TransactionCategory.transport:
        return 'Di chuyển';
      case TransactionCategory.shopping:
        return 'Mua sắm';
      case TransactionCategory.work:
        return 'Thu nhập';
      case TransactionCategory.health:
        return 'Sức khỏe';
      case TransactionCategory.entertainment:
        return 'Giải trí';
      case TransactionCategory.other:
        return 'Khác';
    }
  }

  /// Tương thích ngược: Lấy Icon emoji đại diện danh mục.
  String get categoryIcon {
    switch (category) {
      case TransactionCategory.food:
        return '🍜';
      case TransactionCategory.transport:
        return '🚗';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.work:
        return '💼';
      case TransactionCategory.health:
        return '❤️‍🩹';
      case TransactionCategory.entertainment:
        return '🎮';
      case TransactionCategory.other:
        return '📦';
    }
  }

  /// Tạo một bản sao mới của [TransactionModel] nhưng thay đổi một vài thuộc tính.
  TransactionModel copyWith({
    String? id,
    String? walletId,
    String? categoryId,
    TransactionCategory? category,
    String? challengeId,
    double? amount,
    TransactionType? type,
    String? title,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      challengeId: challengeId ?? this.challengeId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      title: title ?? this.title,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Chuyển đổi đối tượng [TransactionModel] sang dạng Map để lưu vào database SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'wallet_id': walletId,
      'category_id': categoryId,
      'category_enum': category.toJson(),
      'challenge_id': challengeId,
      'amount': amount,
      'type': type.toJson(),
      'title': title,
      'note': note,
      'date': date.millisecondsSinceEpoch,
      'created_at': (createdAt ?? date).millisecondsSinceEpoch,
    };
  }

  /// Khởi tạo đối tượng [TransactionModel] từ dữ liệu Map lấy từ database SQLite.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    final typeVal = TransactionType.fromJson(map['type'] as String);
    final catEnumVal = map['category_enum'] != null 
        ? TransactionCategory.fromJson(map['category_enum'] as String)
        : (typeVal == TransactionType.income ? TransactionCategory.work : TransactionCategory.other);

    return TransactionModel(
      id: map['id'] as String,
      walletId: map['wallet_id'] as String,
      categoryId: map['category_id'] as String? ?? catEnumVal.name,
      category: catEnumVal,
      challengeId: map['challenge_id'] as String?,
      amount: (map['amount'] as num).toDouble(),
      type: typeVal,
      title: map['title'] as String,
      note: map['note'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      createdAt: map['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
    );
  }

  /// Chuyển đổi đối tượng [TransactionModel] sang chuỗi JSON.
  String toJson() => json.encode(toMap());

  /// Khởi tạo đối tượng [TransactionModel] từ chuỗi JSON.
  factory TransactionModel.fromJson(String source) => 
      TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
        id,
        walletId,
        categoryId,
        category,
        challengeId,
        amount,
        type,
        title,
        note,
        date,
        createdAt,
      ];
}
