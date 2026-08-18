import 'package:finio/app_localizations.dart';

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
    _ => name,
  };
}
