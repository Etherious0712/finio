import 'package:intl/intl.dart';

final _fmt = NumberFormat('#,##0.00');

String formatAmount(double amount, String symbol) =>
    '$symbol${_fmt.format(amount)}';
