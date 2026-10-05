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
