import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// {@template category}
/// Đại diện cho một Danh mục phân loại giao dịch (ví dụ: Ăn uống, Di chuyển).
/// 
/// Lớp này hỗ trợ phân biệt danh mục hệ thống mặc định (`isSystem = true`) 
/// và các danh mục do người dùng tự tạo bổ sung.
/// {@endtemplate}
@immutable
class CategoryModel extends Equatable {
  /// Mã định danh duy nhất của danh mục.
  final String id;

  /// Tên hiển thị của danh mục (ví dụ: "Ăn uống").
  final String name;

  /// Emoji hoặc ký tự hiển thị biểu tượng đại diện (ví dụ: "🍜").
  final String icon;

  /// Loại giao dịch mà danh mục này áp dụng ("income", "expense", "both").
  final String type;

  /// Mã màu Hex đại diện (ví dụ: "#FF5733").
  final String color;

  /// Cho biết danh mục này có phải do hệ thống tự sinh và không thể xóa hay không.
  final bool isSystem;

  /// {@macro category}
  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.color,
    required this.isSystem,
  });

  /// Tạo một bản sao mới của [CategoryModel] nhưng thay đổi một vài thuộc tính.
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? type,
    String? color,
    bool? isSystem,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  /// Chuyển đổi đối tượng [CategoryModel] sang dạng Map để lưu vào database SQLite.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'icon': icon,
      'type': type,
      'color': color,
      'is_system': isSystem ? 1 : 0,
    };
  }

  /// Khởi tạo đối tượng [CategoryModel] từ dữ liệu Map lấy từ database SQLite.
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      type: map['type'] as String,
      color: map['color'] as String,
      isSystem: (map['is_system'] as int) == 1,
    );
  }

  /// Chuyển đổi đối tượng [CategoryModel] sang chuỗi JSON.
  String toJson() => json.encode(toMap());

  /// Khởi tạo đối tượng [CategoryModel] từ chuỗi JSON.
  factory CategoryModel.fromJson(String source) => 
      CategoryModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [id, name, icon, type, color, isSystem];
}
