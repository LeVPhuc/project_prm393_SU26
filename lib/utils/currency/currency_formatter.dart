import 'package:intl/intl.dart';

/// {@template currency_formatter}
/// Centralized utility for formatting numbers into standard Vietnamese Dong (VND) representations.
/// {@endtemplate}
class CurrencyFormatter {
  // Use a dot '.' as a grouping separator. Standard 'vi_VN' locale in the intl package handles this.
  static final NumberFormat _vndFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

  /// Formats a number to Vietnamese Dong format without the currency symbol suffix.
  /// 
  /// Example:
  /// ```dart
  /// CurrencyFormatter.format(1000) // "1.000"
  /// CurrencyFormatter.format(1000000) // "1.000.000"
  /// ```
  static String format(num amount) {
    // Trim to clean up any leading/trailing spaces added by the formatter
    return _vndFormatter.format(amount).trim();
  }

  /// Formats a number to Vietnamese Dong format with a currency symbol suffix.
  /// 
  /// Example:
  /// ```dart
  /// CurrencyFormatter.formatWithSymbol(1000) // "1.000 đ"
  /// CurrencyFormatter.formatWithSymbol(1000000) // "1.000.000 đ"
  /// ```
  static String formatWithSymbol(num amount, {String symbol = 'đ'}) {
    final formattedValue = format(amount);
    return '$formattedValue $symbol';
  }
}
