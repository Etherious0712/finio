import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Cash-register amount entry: every digit typed shifts in from the right, so
/// the field always carries exactly two decimals — `1` → `0.01`, `12` → `0.12`,
/// `1234` → `12.34`. Pairs with [TextInputType.number]; the decimal point is
/// never typed, which is what makes "two decimals" impossible to get wrong.
///
/// The value is held as whole cents, never as a double mid-edit, so there is
/// no floating-point drift between what's shown and what's saved.
class CentsInputFormatter extends TextInputFormatter {
  const CentsInputFormatter({this.maxDigits = 12});

  /// Cap on typed digits (12 = up to 9,999,999,999.99).
  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digitsOf(newValue.text).replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > maxDigits) return oldValue;
    final cents = int.tryParse(digits) ?? 0;
    // Empty (or all zeros erased) shows the 0.00 hint rather than a value.
    final text = cents == 0 ? '' : formatCents(cents);
    return TextEditingValue(
      text: text,
      // Digits only ever enter at the right, so the caret lives there.
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Grouped, two-decimal rendering of [cents] in the active locale.
String formatCents(int cents) => NumberFormat('#,##0.00').format(cents / 100);

/// The amount a [CentsInputFormatter] field holds, or null when it's empty.
double? parseCentsInput(String text) {
  final digits = _digitsOf(text);
  if (digits.isEmpty) return null;
  return int.parse(digits) / 100;
}

/// Initial field text for an existing [amount] (editing a record, a budget, an
/// opening balance). Zero gives an empty field so the hint shows.
String centsTextFor(double amount) {
  final cents = (amount.abs() * 100).round();
  return cents == 0 ? '' : formatCents(cents);
}

String _digitsOf(String text) => text.replaceAll(RegExp(r'[^0-9]'), '');
