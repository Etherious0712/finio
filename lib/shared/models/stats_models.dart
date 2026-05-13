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
