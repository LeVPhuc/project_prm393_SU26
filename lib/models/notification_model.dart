import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Các trạng thái của thông báo.
enum NotificationStatus {
  /// Thông báo đã được lên lịch nhưng chưa hiển thị.
  pending,

  /// Thông báo đã được gửi đến thiết bị của người dùng.
  delivered,

  /// Người dùng đã đọc thông báo này.
  read;

  /// Chuyển sang JSON string.
  String toJson() => name;

  /// Khôi phục từ JSON string.
  static NotificationStatus fromJson(String name) {
    return NotificationStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => NotificationStatus.pending,
    );
  }
}

/// {@template notification}
/// Đại diện cho bản ghi thông báo (Nhắc nhở, Cảnh báo cược) trong hệ thống.
/// {@endtemplate}
@immutable
class NotificationModel extends Equatable {
  /// Mã định danh duy nhất của thông báo.
  final String id;

  /// Người nhận thông báo.
  final String userId;

  /// Tiêu đề của thông báo.
  final String title;

  /// Nội dung chi tiết của thông báo.
  final String body;

  /// Trạng thái gửi/đọc của thông báo.
  final NotificationStatus status;

  /// Thời điểm dự kiến thông báo được kích hoạt hiển thị.
  final DateTime scheduledAt;

  /// {@macro notification}
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.status,
    required this.scheduledAt,
  });

  /// Tạo một bản sao mới.
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationStatus? status,
    DateTime? scheduledAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  /// Chuyển đổi sang Map để lưu SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'status': status.toJson(),
      'scheduled_at': scheduledAt.millisecondsSinceEpoch,
    };
  }

  /// Khởi tạo từ Map SQLite.
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      status: NotificationStatus.fromJson(map['status'] as String),
      scheduledAt: DateTime.fromMillisecondsSinceEpoch(map['scheduled_at'] as int),
    );
  }

  /// Chuyển đổi sang JSON.
  String toJson() => json.encode(toMap());

  /// Khởi tạo từ JSON.
  factory NotificationModel.fromJson(String source) => 
      NotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [id, userId, title, body, status, scheduledAt];
}
