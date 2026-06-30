import 'package:intl/intl.dart';

/// Formats an amount with the currency symbol prefixed. The number itself is
/// built per call (not cached) so it follows the active [Intl.defaultLocale] —
/// e.g. German renders `4.594,20`. The symbol stays prefixed because the
/// currency is a user setting independent of the app language.
String formatAmount(double amount, String symbol) =>
    '$symbol${NumberFormat('#,##0.00').format(amount)}';
