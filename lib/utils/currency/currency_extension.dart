import 'currency_formatter.dart';

/// {@template currency_extension}
/// Syntactic sugar extensions on [num] to format numbers into Vietnamese Dong representations.
/// {@endtemplate}
extension CurrencyExtension on num {
  /// Converts the number to a formatted Vietnamese Dong string without currency symbol.
  /// 
  /// Example:
  /// ```dart
  /// 1000000.toVndRaw() // "1.000.000"
  /// ```
  String toVndRaw() {
    return CurrencyFormatter.format(this);
  }

  /// Converts the number to a formatted Vietnamese Dong string with 'đ' currency symbol.
  /// 
  /// Example:
  /// ```dart
  /// 1000000.toVnd() // "1.000.000 đ"
  /// ```
  String toVnd() {
    return CurrencyFormatter.formatWithSymbol(this);
  }

  /// Converts the number to a compact Vietnamese Dong representation.
  /// 
  /// - Under 1.000: Displays the full amount with "đ" symbol.
  /// - 1.000 to under 1.000.000: Formats in K (Nghìn) (e.g., 150000 -> "150 K").
  /// - 1.000.000 to under 1.000.000.000: Formats in Tr (Triệu) (e.g., 1500000 -> "1,5 Tr").
  /// - 1.000.000.000 and above: Formats in Tỷ (Tỷ) (e.g., 2000000000 -> "2 Tỷ").
  /// 
  /// Uses a comma ',' as a decimal separator in short representations where appropriate.
  /// 
  /// Example:
  /// ```dart
  /// 500.toVndShort() // "500 đ"
  /// 12500.toVndShort() // "12,5 K"
  /// 1500000.toVndShort() // "1,5 Tr"
  /// 2000000000.toVndShort() // "2 Tỷ"
  /// ```
  String toVndShort() {
    final absValue = abs();
    final sign = this < 0 ? '-' : '';

    if (absValue >= 1000000000) {
      final value = absValue / 1000000000;
      final formatted = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
      return '$sign${formatted.replaceAll('.', ',')} Tỷ';
    } else if (absValue >= 1000000) {
      final value = absValue / 1000000;
      final formatted = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
      return '$sign${formatted.replaceAll('.', ',')} Tr';
    } else if (absValue >= 1000) {
      final value = absValue / 1000;
      final formatted = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
      return '$sign${formatted.replaceAll('.', ',')} K';
    }
    return toVnd();
  }
}
