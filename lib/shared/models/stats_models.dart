class CategoryStat {
  final String category;
  final String icon;
  final String color;
  final double amount;
  final double percentage;

  const CategoryStat({
    required this.category,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
  });
}

/// Running net balance of one savings jar. Not a [CategoryStat]: a balance can
/// be negative, which makes a percentage-of-total meaningless.
class AccountBalance {
  /// Jar name, or empty for the "unassigned" bucket.
  final String name;
  final String icon;
  final String color;

  /// All-time income − expense for this jar. May be negative.
  final double balance;

  const AccountBalance({
    required this.name,
    required this.icon,
    required this.color,
    required this.balance,
  });

  bool get isUnassigned => name.isEmpty;
}

class MonthSummary {
  final DateTime month;
  final double income;
  final double expense;

  const MonthSummary({
    required this.month,
    required this.income,
    required this.expense,
  });
}
