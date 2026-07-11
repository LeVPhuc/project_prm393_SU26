import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:appvunven/utils/currency/currency_formatter.dart';
import 'package:appvunven/utils/currency/currency_parser.dart';
import 'package:appvunven/utils/currency/currency_extension.dart';
import 'package:appvunven/utils/currency/currency_text_field.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('Format positive integers', () {
      expect(CurrencyFormatter.format(0), '0');
      expect(CurrencyFormatter.format(1000), '1.000');
      expect(CurrencyFormatter.format(1000000), '1.000.000');
      expect(CurrencyFormatter.format(999999999), '999.999.999');
    });

    test('Format with symbol (đ)', () {
      expect(CurrencyFormatter.formatWithSymbol(0), '0 đ');
      expect(CurrencyFormatter.formatWithSymbol(1000), '1.000 đ');
      expect(CurrencyFormatter.formatWithSymbol(1000000), '1.000.000 đ');
    });
  });

  group('CurrencyParser Tests', () {
    test('Parse formatted strings to double', () {
      expect(CurrencyParser.parse('0'), 0.0);
      expect(CurrencyParser.parse('1.000'), 1000.0);
      expect(CurrencyParser.parse('1.000.000'), 1000000.0);
      expect(CurrencyParser.parse('1.000.000 đ'), 1000000.0);
      expect(CurrencyParser.parse('  1.000.000 đ  '), 1000000.0);
    });

    test('Parse negative formatted strings', () {
      expect(CurrencyParser.parse('-1.000'), -1000.0);
      expect(CurrencyParser.parse('-1.000.000 đ'), -1000000.0);
    });

    test('Parse empty or invalid strings', () {
      expect(CurrencyParser.parse(''), 0.0);
      expect(CurrencyParser.parse('-'), 0.0);
      expect(CurrencyParser.parse('đ'), 0.0);
      expect(CurrencyParser.parse('abc'), 0.0);
    });
  });

  group('CurrencyExtension Tests', () {
    test('toVndRaw extension', () {
      expect(1250000.toVndRaw(), '1.250.000');
    });

    test('toVnd extension', () {
      expect(1250000.toVnd(), '1.250.000 đ');
    });

    test('toVndShort extension (VND short units)', () {
      expect(500.toVndShort(), '500 đ');
      expect(1200.toVndShort(), '1,2 K');
      expect(12000.toVndShort(), '12 K');
      expect(1500000.toVndShort(), '1,5 Tr');
      expect(15000000.toVndShort(), '15 Tr');
      expect(2000000000.toVndShort(), '2 Tỷ');
      expect(2500000000.toVndShort(), '2,5 Tỷ');
    });

    test('toVndShort extension with negative values', () {
      expect((-1200).toVndShort(), '-1,2 K');
      expect((-1500000).toVndShort(), '-1,5 Tr');
      expect((-2000000000).toVndShort(), '-2 Tỷ');
    });
  });

  group('VndCurrencyInputFormatter Tests', () {
    final formatter = VndCurrencyInputFormatter();

    test('Format typed input', () {
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: '1000',
        selection: TextSelection.collapsed(offset: 4),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '1.000');
      // Cursor should be at the end of formatted text
      expect(result.selection.end, 5);
    });

    test('Format typed input with cursor in the middle', () {
      const oldValue = TextEditingValue(
        text: '1.000',
        selection: TextSelection.collapsed(offset: 1), // cursor after '1' -> '1|000'
      );
      const newValue = TextEditingValue(
        text: '12.000',
        selection: TextSelection.collapsed(offset: 2), // user typed '2' -> '12|.000'
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      expect(result.text, '12.000');
      expect(result.selection.end, 2); // Cursor should remain correctly after '2' -> '12|.000'
    });

    test('Smart Backspace handling: deleting a dot separator', () {
      // Old state is '1.000' with cursor after '.' (so '1.|000', selection offset 2)
      const oldValue = TextEditingValue(
        text: '1.000',
        selection: TextSelection.collapsed(offset: 2),
      );
      // User presses Backspace, which deletes '.' -> '1000' (selection offset 1)
      const newValue = TextEditingValue(
        text: '1000',
        selection: TextSelection.collapsed(offset: 1),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      // The formatter should detect that the dot was deleted and also delete the '1' before it,
      // resulting in '000' which parses to 0 and outputs empty/nothing.
      expect(result.text, '');
      expect(result.selection.end, 0);
    });

    test('Backspace deleting dot on larger number', () {
      // Old state: '12.345' with cursor after '.' -> '12.|345' (selection offset 3)
      const oldValue = TextEditingValue(
        text: '12.345',
        selection: TextSelection.collapsed(offset: 3),
      );
      // User presses Backspace, deleting '.' -> '12345' (selection offset 2)
      const newValue = TextEditingValue(
        text: '12345',
        selection: TextSelection.collapsed(offset: 2),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);
      // Formatter deletes the '2' preceding the dot -> '1345', formatted to '1.345'
      expect(result.text, '1.345');
      // Cursor should be positioned after '1' -> '1|.345' (selection offset 1)
      expect(result.selection.end, 1);
    });
  });
}
