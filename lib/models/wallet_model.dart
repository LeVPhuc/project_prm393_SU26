import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Hỗ trợ tương thích ngược với code cũ.
typedef Wallet = WalletModel;

/// {@template wallet}
/// Đại diện cho thực thể Ví tài chính trong hệ thống Vún Vén.
/// 
/// Hỗ trợ quản lý số dư khả dụng (`availableBalance`) và số dư bị đóng băng
/// (`frozenBalance`) cho mục đích cược thử thách Self-Gambling.
/// {@endtemplate}
@immutable
class WalletModel extends Equatable {
  /// Mã định danh duy nhất của ví (UUID v4).
  final String id;

  /// Mã định danh người dùng sở hữu ví này.
  final String userId;

  /// Tên ví (ví dụ: "Ví Tiền Mặt", "Ví Ngân Hàng").
  final String name;

  /// Tổng số dư hiện có trong ví (bao gồm cả tiền đóng băng).
  final double balance;

  /// Khoản tiền đang bị đóng băng để cược trong các Thách đấu.
  final double frozenBalance;

  /// Đơn vị tiền tệ sử dụng (ví dụ: "VND", "USD").
  final String currency;

  /// Nhãn hiển thị icon đại diện cho ví (Emoji hoặc Icon Key).
  final String icon;

  /// Chỉ mục màu sắc phục vụ hiển thị giao diện.
  final int colorIndex;

  /// Loại ví (ví dụ: "cash", "bank", "savings").
  final String type;

  /// Cho biết ví này có phải là ví giao dịch mặc định không.
  final bool isDefault;

  /// Thời điểm cập nhật dữ liệu ví lần cuối.
  final DateTime? updatedAt;

  /// {@macro wallet}
  const WalletModel({
    required this.id,
    this.userId = 'user123', // Mặc định để tương thích code cũ
    required this.name,
    required this.balance,
    this.frozenBalance = 0.0, // Mặc định để tương thích
    this.currency = 'VND', // Mặc định để tương thích
    required this.icon,
    required this.colorIndex,
    required this.type,
    this.isDefault = false, // Mặc định để tương thích
    this.updatedAt,
  });

  /// Tính toán số dư thực tế người dùng có thể chi tiêu.
  double get availableBalance => balance - frozenBalance;

  /// Tạo một bản sao mới của [WalletModel] nhưng thay đổi một vài thuộc tính.
  WalletModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? balance,
    double? frozenBalance,
    String? currency,
    String? icon,
    int? colorIndex,
    String? type,
    bool? isDefault,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      frozenBalance: frozenBalance ?? this.frozenBalance,
      currency: currency ?? this.currency,
      icon: icon ?? this.icon,
      colorIndex: colorIndex ?? this.colorIndex,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Chuyển đổi đối tượng [WalletModel] sang dạng Map để lưu vào database SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'name': name,
      'balance': balance,
      'frozen_balance': frozenBalance,
      'currency': currency,
      'icon': icon,
      'color_index': colorIndex,
      'type': type,
      'is_default': isDefault ? 1 : 0,
      'updated_at': (updatedAt ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }

  /// Khởi tạo đối tượng [WalletModel] từ dữ liệu Map lấy từ database SQLite.
  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? 'user123',
      name: map['name'] as String,
      balance: (map['balance'] as num).toDouble(),
      frozenBalance: (map['frozen_balance'] as num? ?? 0.0).toDouble(),
      currency: map['currency'] as String? ?? 'VND',
      icon: map['icon'] as String,
      colorIndex: map['color_index'] as int,
      type: map['type'] as String,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  /// Chuyển đổi đối tượng [WalletModel] sang chuỗi JSON.
  String toJson() => json.encode(toMap());

  /// Khởi tạo đối tượng [WalletModel] từ chuỗi JSON.
  factory WalletModel.fromJson(String source) => 
      WalletModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        balance,
        frozenBalance,
        currency,
        icon,
        colorIndex,
        type,
        isDefault,
        updatedAt,
      ];
}
