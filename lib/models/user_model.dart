import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// {@template user}
/// Đại diện cho thực thể người dùng trong hệ thống Vún Vén.
/// 
/// Lớp này là bất biến (immutable) và hỗ trợ các cơ chế so sánh giá trị (Equatable),
/// sao chép (copyWith) và tuần tự hóa dữ liệu (JSON/Map serialization).
/// {@endtemplate}
@immutable
class UserModel extends Equatable {
  /// Mã định danh duy nhất của người dùng (UUID v4).
  final String id;

  /// Tên hiển thị của người dùng.
  final String username;

  /// Chuỗi ngày/tuần hoàn thành thách đấu liên tục (Streak).
  final int streakCount;

  /// Thời điểm tài khoản được khởi tạo.
  final DateTime createdAt;

  /// {@macro user}
  const UserModel({
    required this.id,
    required this.username,
    required this.streakCount,
    required this.createdAt,
  });

  /// Tạo một bản sao mới của [UserModel] nhưng thay đổi một vài thuộc tính.
  UserModel copyWith({
    String? id,
    String? username,
    int? streakCount,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      streakCount: streakCount ?? this.streakCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Chuyển đổi đối tượng [UserModel] sang dạng Map để lưu vào database SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'streak_count': streakCount,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Khởi tạo đối tượng [UserModel] từ dữ liệu Map lấy từ database SQLite.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      streakCount: map['streak_count'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// Chuyển đổi đối tượng [UserModel] sang chuỗi JSON.
  String toJson() => json.encode(toMap());

  /// Khởi tạo đối tượng [UserModel] từ chuỗi JSON.
  factory UserModel.fromJson(String source) => 
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [id, username, streakCount, createdAt];
}
