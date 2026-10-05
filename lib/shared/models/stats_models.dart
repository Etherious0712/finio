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

  /// Opening balance plus all-time income + refunds − expense ± transfers. May
  /// be negative — a credit card usually is.
  final double balance;

  /// Credit cards only; null when not set.
  final double? creditLimit;

  const AccountBalance({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.balance,
    this.creditLimit,
  });

  bool get isUnassigned => name.isEmpty;

  bool get isCreditCard => type == 'creditCard';

  /// What a card owes: the balance's negative side, shown as a positive.
  double get owed => balance < 0 ? -balance : 0;

  /// A card paid past zero holds the bank's money — an overpayment.
  double get overpaid => balance > 0 ? balance : 0;

  /// Credit left to spend: limit − owed, plus any overpayment, so it can
  /// exceed the limit. Null when the card has no limit set.
  double? get available =>
      creditLimit == null ? null : creditLimit! + balance;
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
