import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'currency_formatter.dart';
import 'currency_parser.dart';

/// {@template vnd_currency_input_formatter}
/// A custom [TextInputFormatter] that formats user input into Vietnamese Dong (VND)
/// in real-time as they type, with smart cursor tracking and backspace handling.
/// {@endtemplate}
class VndCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String textToParse = newValue.text;
    int cursorPosition = newValue.selection.end;

    // Detect if a grouping separator '.' was deleted by backspacing.
    // If so, we also delete the digit immediately preceding the dot.
    if (oldValue.text.length - newValue.text.length == 1 &&
        oldValue.selection.end > 0 &&
        oldValue.selection.end <= oldValue.text.length &&
        oldValue.text[oldValue.selection.end - 1] == '.') {
      final oldCursor = oldValue.selection.end;
      final partBeforeDot = oldValue.text.substring(0, oldCursor - 1);
      final partAfterDot = oldValue.text.substring(oldCursor);

      if (partBeforeDot.isNotEmpty) {
        final newPartBefore = partBeforeDot.substring(0, partBeforeDot.length - 1);
        textToParse = newPartBefore + partAfterDot;
        cursorPosition = newPartBefore.length;
      } else {
        textToParse = partAfterDot;
        cursorPosition = 0;
      }
    }

    // Retain only digits
    final cleanText = textToParse.replaceAll(RegExp(r'\D'), '');
    if (cleanText.isEmpty || (double.tryParse(cleanText) == 0 && cleanText.length > 1)) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final amount = double.tryParse(cleanText) ?? 0.0;
    final formattedText = CurrencyFormatter.format(amount);

    // Calculate the new cursor position after formatting is applied
    int selectionIndex = formattedText.length;

    if (cursorPosition != -1) {
      // Find how many digits were before the cursor in the unformatted updated text
      final textBeforeCursor = textToParse.substring(0, cursorPosition.clamp(0, textToParse.length).toInt());
      final digitsBeforeCursor = textBeforeCursor.replaceAll(RegExp(r'\D'), '').length;

      if (digitsBeforeCursor == 0) {
        selectionIndex = 0;
      } else {
        int digitsSeen = 0;
        int newCursorPosition = 0;
        for (int i = 0; i < formattedText.length; i++) {
          if (RegExp(r'\d').hasMatch(formattedText[i])) {
            digitsSeen++;
          }
          newCursorPosition = i + 1;
          if (digitsSeen == digitsBeforeCursor) {
            break;
          }
        }
        selectionIndex = newCursorPosition.clamp(0, formattedText.length);
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// {@template currency_text_field}
/// A customized [TextFormField] widget tailored for Vietnamese Dong (VND) input.
/// 
/// Handles real-time formatting (adding thousand separator dots) and exposes a parsed
/// double callback for direct fintech logic integration.
/// {@endtemplate}
class CurrencyTextField extends StatelessWidget {
  /// The controller to monitor and update input text.
  final TextEditingController? controller;

  /// Optional initial value to pre-fill the text field.
  final String? initialValue;

  /// Callback returning the raw parsed [double] representation of the money input.
  final ValueChanged<double>? onChanged;

  /// Input validator helper for standard Flutter form validation.
  final FormFieldValidator<String>? validator;

  /// The input decoration to style the text field. Defaults to displaying a trailing 'đ' symbol.
  final InputDecoration? decoration;

  /// The text style of the input text.
  final TextStyle? style;

  /// The text alignment inside the input. Defaults to [TextAlign.end].
  final TextAlign textAlign;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether the field is enabled.
  final bool enabled;

  /// {@macro currency_text_field}
  const CurrencyTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.decoration,
    this.style,
    this.textAlign = TextAlign.end,
    this.readOnly = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
      inputFormatters: [
        VndCurrencyInputFormatter(),
      ],
      textAlign: textAlign,
      style: style,
      readOnly: readOnly,
      enabled: enabled,
      decoration: decoration ?? const InputDecoration(
        suffixText: 'đ',
        hintText: '0',
      ),
      onChanged: (value) {
        if (onChanged != null) {
          final parsedValue = CurrencyParser.parse(value);
          onChanged!(parsedValue);
        }
      },
      validator: validator,
    );
  }
}
