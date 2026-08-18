import 'package:finio/app_localizations.dart';

/// The account types, in picker order. Stored in `accounts.type`.
const kAccountTypes = ['cash', 'bank', 'creditCard', 'eWallet', 'savings'];

/// Translates a stored account type key to its display name. Unknown keys are
/// returned as-is.
String localizeAccountType(AppLocalizations l, String type) {
  return switch (type) {
    'cash' => l.acctCash,
    'bank' => l.acctBank,
    'creditCard' => l.acctCreditCard,
    'eWallet' => l.acctEWallet,
    'savings' => l.acctSavings,
    _ => type,
  };
}

/// Icon preselected when the user picks a type and hasn't chosen one.
String defaultIconForAccountType(String type) {
  return switch (type) {
    'cash' => 'payments',
    'bank' => 'account_balance',
    'creditCard' => 'credit_card',
    'eWallet' => 'account_balance_wallet',
    _ => 'savings',
  };
}
