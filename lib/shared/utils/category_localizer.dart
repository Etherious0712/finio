import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';

/// Translates a stored category key (e.g. 'catFood') to the localized display
/// name. Custom categories (not matching any key) are returned as-is.
String localizeCategory(AppLocalizations l, String name) {
  return switch (name) {
    'catFood' => l.catFood,
    'catTransport' => l.catTransport,
    'catShopping' => l.catShopping,
    'catEntertainment' => l.catEntertainment,
    'catHealth' => l.catHealth,
    'catBills' => l.catBills,
    'catOtherExpense' => l.catOtherExpense,
    'catSalary' => l.catSalary,
    'catFreelance' => l.catFreelance,
    'catInvestment' => l.catInvestment,
    'catOtherIncome' => l.catOtherIncome,
    // Reserved key for transfers. Deliberately absent from the categories
    // table, so it never shows up in the picker or in budgets.
    'catTransfer' => l.catTransfer,
    // Reserved the same way, for a transfer that pays down a credit card.
    'catCardPayment' => l.cardPayment,
    _ => name,
  };
}

/// What to show as [tx]'s title: the note the user typed, or the localized
/// category when they typed none. Rows written before this fix stored the raw
/// category key here, which put a literal 'catOtherIncome' on the dashboard.
String transactionTitle(AppLocalizations l, Transaction tx) =>
    tx.title.isNotEmpty ? tx.title : localizeCategory(l, tx.category);

/// Key into the `'type:name'` category maps for [tx]. A refund files under an
/// expense category, so it looks up the expense side.
String categoryKeyOf(Transaction tx) =>
    '${tx.type == 'refund' ? 'expense' : tx.type}:${tx.category}';

/// What [tx] adds to spending: an expense in full, a refund takes it back,
/// anything else (income, transfers) nothing.
double spendOf(Transaction tx) => switch (tx.type) {
      'expense' => tx.amount,
      'refund' => -tx.amount,
      _ => 0,
    };
