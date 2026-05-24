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
    _ => name,
  };
}
