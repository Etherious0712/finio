import 'package:intl/intl.dart';

/// Formats an amount with the currency symbol prefixed. The number itself is
/// built per call (not cached) so it follows the active [Intl.defaultLocale] —
/// e.g. German renders `4.594,20`. The symbol stays prefixed because the
/// currency is a user setting independent of the app language.
///
/// The minus goes outside the symbol (`-$80.00`, not `$-80.00`) — credit-card
/// balances are negative by nature, so this shows up constantly.
String formatAmount(double amount, String symbol) {
  final n = NumberFormat('#,##0.00').format(amount.abs());
  return amount < 0 ? '-$symbol$n' : '$symbol$n';
}

/// Formats a mid-typing amount string from `AmountKeypad` for display: groups
/// the integer part but leaves the in-progress decimals alone, so "12." and
/// "12.5" don't jump to "12.00"/"12.50" under the user's fingers. Empty shows
/// 0.00 because that's a settled value, not a half-typed one.
// ponytail: the decimal point stays ASCII since the keypad only types '.';
// localize it when the keypad does.
String formatAmountInput(String raw) {
  if (raw.isEmpty) return NumberFormat('#,##0.00').format(0);
  final dot = raw.indexOf('.');
  final intPart = dot < 0 ? raw : raw.substring(0, dot);
  final n = int.tryParse(intPart);
  if (n == null) return raw; // absurdly long input — show it raw, don't crash
  return NumberFormat('#,##0').format(n) + (dot < 0 ? '' : raw.substring(dot));
}
