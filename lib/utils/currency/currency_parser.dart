/// {@template currency_parser}
/// Centralized utility for parsing formatted Vietnamese Dong (VND) strings back into raw numeric values.
/// {@endtemplate}
class CurrencyParser {
  /// Parses a formatted Vietnamese Dong (VND) string back into a double.
  /// 
  /// Removes all formatting elements (dots, currency symbols, spaces, letters).
  /// Safely handles empty strings, null-like values, and negative signs.
  /// 
  /// Example:
  /// ```dart
  /// CurrencyParser.parse("1.000.000 đ") // 1000000.0
  /// CurrencyParser.parse("2.500") // 2500.0
  /// CurrencyParser.parse("-150.000") // -150000.0
  /// ```
  static double parse(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 0.0;

    // Retain only digits and negative signs
    final cleanValue = trimmed.replaceAll(RegExp(r'[^0-9\-]'), '');
    
    if (cleanValue.isEmpty || cleanValue == '-') {
      return 0.0;
    }

    return double.tryParse(cleanValue) ?? 0.0;
  }
}
