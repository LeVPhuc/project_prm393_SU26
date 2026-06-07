import 'package:flutter/services.dart';

class MoneyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');

    // Loại bỏ dấu chấm cũ để định dạng lại từ đầu
    String cleanText = newValue.text.replaceAll('.', '');

    // Thuật toán chèn dấu chấm hàng nghìn
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedText = cleanText.replaceAllMapped(reg, (Match match) => '${match[1]}.');

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}