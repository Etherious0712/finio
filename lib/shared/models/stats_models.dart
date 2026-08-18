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

/// Running net balance of one account. Not a [CategoryStat]: a balance can be
/// negative, which makes a percentage-of-total meaningless.
class AccountBalance {
  /// Account name, or empty for the "unassigned" bucket.
  final String name;
  final String icon;
  final String color;

  /// Account type key, or empty for the "unassigned" bucket.
  final String type;

  /// Opening balance plus all-time income − expense ± transfers. May be
  /// negative — a credit card usually is.
  final double balance;

  const AccountBalance({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
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
