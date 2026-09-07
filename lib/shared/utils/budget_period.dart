import 'package:finio/core/database/app_database.dart';

/// The `[start, end)` window a [period] budget covers around [anchor].
///
// ponytail: ISO week (Monday start), hardcoded. A locale-aware first day would
// make the same budget report a different total when the user switches app
// language — worse than being Sunday-unfriendly for one locale.
(DateTime, DateTime) budgetWindow(String period, DateTime anchor) {
  switch (period) {
    case 'week':
      // Day arithmetic rather than Duration: a DST boundary must not make the
      // window 23 or 25 hours long. Dart weekday is 1=Mon..7=Sun.
      final s = DateTime(
          anchor.year, anchor.month, anchor.day - (anchor.weekday - 1));
      return (s, DateTime(s.year, s.month, s.day + 7));
    case 'year':
      return (DateTime(anchor.year), DateTime(anchor.year + 1));
    default: // 'month'
      return (
        DateTime(anchor.year, anchor.month),
        DateTime(anchor.year, anchor.month + 1),
      );
  }
}

/// The amount in force for the window starting at [start]: the single-month
/// override when it names that month, otherwise the recurring amount.
///
/// Guards on `period == 'month'` so an override left behind by a period switch
/// is inert — a month override of a weekly or yearly budget is meaningless.
double effectiveBudget(Budget b, DateTime start) =>
    (b.period == 'month' &&
            b.overrideAmount != null &&
            b.month == start.month &&
            b.year == start.year)
        ? b.overrideAmount!
        : b.amount;
