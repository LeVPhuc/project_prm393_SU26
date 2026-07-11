import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// {@template achievement}
/// Định nghĩa một Thành tích/Huy chương trong hệ thống (Gamification).
/// {@endtemplate}
@immutable
class AchievementModel extends Equatable {
  /// Mã định danh duy nhất của thành tích.
  final String id;

  /// Tên của thành tích (ví dụ: "Chiến thần kỷ luật").
  final String title;

  /// Điều kiện hoặc mô tả cách thức đạt thành tích.
  final String description;

  /// Key để map với asset hình ảnh hoặc Lottie animation ở giao diện.
  final String iconKey;

  /// {@macro achievement}
  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconKey,
  });

  /// Tạo một bản sao mới của [AchievementModel] nhưng thay đổi một vài thuộc tính.
  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? iconKey,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
    );
  }

  /// Chuyển đổi đối tượng [AchievementModel] sang dạng Map để lưu vào database SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'icon_key': iconKey,
    };
  }

  /// Khởi tạo đối tượng [AchievementModel] từ dữ liệu Map lấy từ database SQLite.
  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    return AchievementModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      iconKey: map['icon_key'] as String,
    );
  }

  /// Chuyển đổi đối tượng [AchievementModel] sang chuỗi JSON.
  String toJson() => json.encode(toMap());

  /// Khởi tạo đối tượng [AchievementModel] từ chuỗi JSON.
  factory AchievementModel.fromJson(String source) => 
      AchievementModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [id, title, description, iconKey];
}

/// {@template user_achievement}
/// Đại diện cho bản ghi chứng nhận một Thành tích đã được mở khóa bởi một người dùng.
/// {@endtemplate}
@immutable
class UserAchievementModel extends Equatable {
  /// ID của người dùng đạt được thành tích.
  final String userId;

  /// ID của thành tích đạt được.
  final String achievementId;

  /// Thời điểm thành tích này được mở khóa.
  final DateTime unlockedAt;

  /// {@macro user_achievement}
  const UserAchievementModel({
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
  });

  /// Tạo một bản sao mới.
  UserAchievementModel copyWith({
    String? userId,
    String? achievementId,
    DateTime? unlockedAt,
  }) {
    return UserAchievementModel(
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// Chuyển đổi sang Map để lưu SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'achievement_id': achievementId,
      'unlocked_at': unlockedAt.millisecondsSinceEpoch,
    };
  }

  /// Khởi tạo từ Map SQLite.
  factory UserAchievementModel.fromMap(Map<String, dynamic> map) {
    return UserAchievementModel(
      userId: map['user_id'] as String,
      achievementId: map['achievement_id'] as String,
      unlockedAt: DateTime.fromMillisecondsSinceEpoch(map['unlocked_at'] as int),
    );
  }

  /// Chuyển đổi sang JSON.
  String toJson() => json.encode(toMap());

  /// Khởi tạo từ JSON.
  factory UserAchievementModel.fromJson(String source) => 
      UserAchievementModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [userId, achievementId, unlockedAt];
}
