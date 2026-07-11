import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Các trạng thái giao dịch đóng băng dòng tiền.
enum FrozenFundStatus {
  /// Tiền cược đang bị khóa cứng trong ví để tham gia thách đấu.
  locked,

  /// Thách đấu hoàn thành, tiền cược được giải phóng và hoàn trả lại ví.
  releasedReturned,

  /// Thách đấu thất bại, tiền cược được giải phóng nhưng chuyển đi (mất).
  releasedLost;

  /// Chuyển enum sang String để lưu SQLite.
  String toJson() => name;

  /// Phục hồi enum từ String SQLite.
  static FrozenFundStatus fromJson(String name) {
    return FrozenFundStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => FrozenFundStatus.locked,
    );
  }
}

/// {@template frozen_fund}
/// Đại diện cho bản ghi Đóng băng dòng tiền trong hệ thống.
/// 
/// Đóng vai trò như một chứng từ sổ cái, ghi lại toàn bộ vòng đời của khoản cược
/// nhằm đối chiếu kiểm tra tính toàn vẹn tài chính, chống mất mát số dư.
/// {@endtemplate}
@immutable
class FrozenFundModel extends Equatable {
  /// Mã định danh duy nhất của bản ghi đóng băng.
  final String id;

  /// Ví chịu trách nhiệm trích xuất tiền đóng băng.
  final String walletId;

  /// Thách đấu liên kết cần đóng băng khoản tiền này.
  final String challengeId;

  /// Số tiền bị đóng băng.
  final double amount;

  /// Trạng thái đóng băng hiện thời.
  final FrozenFundStatus status;

  /// Thời điểm bắt đầu khóa tiền.
  final DateTime createdAt;

  /// Thời điểm giải tỏa dòng tiền (Hoàn trả hoặc Xử phạt).
  final DateTime? releasedAt;

  /// {@macro frozen_fund}
  const FrozenFundModel({
    required this.id,
    required this.walletId,
    required this.challengeId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.releasedAt,
  });

  /// Tạo một bản sao mới của [FrozenFundModel] nhưng thay đổi một vài thuộc tính.
  FrozenFundModel copyWith({
    String? id,
    String? walletId,
    String? challengeId,
    double? amount,
    FrozenFundStatus? status,
    DateTime? createdAt,
    DateTime? releasedAt,
  }) {
    return FrozenFundModel(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      challengeId: challengeId ?? this.challengeId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      releasedAt: releasedAt ?? this.releasedAt,
    );
  }

  /// Chuyển đổi đối tượng [FrozenFundModel] sang dạng Map để lưu vào database SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'wallet_id': walletId,
      'challenge_id': challengeId,
      'amount': amount,
      'status': status.toJson(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'released_at': releasedAt?.millisecondsSinceEpoch,
    };
  }

  /// Khởi tạo đối tượng [FrozenFundModel] từ dữ liệu Map lấy từ database SQLite.
  factory FrozenFundModel.fromMap(Map<String, dynamic> map) {
    return FrozenFundModel(
      id: map['id'] as String,
      walletId: map['wallet_id'] as String,
      challengeId: map['challenge_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      status: FrozenFundStatus.fromJson(map['status'] as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      releasedAt: map['released_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['released_at'] as int) 
          : null,
    );
  }

  /// Chuyển đổi đối tượng [FrozenFundModel] sang chuỗi JSON.
  String toJson() => json.encode(toMap());

  /// Khởi tạo đối tượng [FrozenFundModel] từ chuỗi JSON.
  factory FrozenFundModel.fromJson(String source) => 
      FrozenFundModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
        id,
        walletId,
        challengeId,
        amount,
        status,
        createdAt,
        releasedAt,
      ];
}
