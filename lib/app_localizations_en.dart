// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get spendingTrend => 'Spending Trend';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get editTransaction => 'Edit Record';

  @override
  String get groupByMonth => 'By Month';

  @override
  String get groupByYear => 'By Year';

  @override
  String get groupByCategory => 'By Category';

  @override
  String get allTime => 'All time';

  @override
  String get vsLastMonth => 'vs last month';

  @override
  String get recordsUsed => 'records';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get appName => 'Finio';

  @override
  String get dashboard => 'Home';

  @override
  String get transactions => 'Records';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get balance => 'Balance';

  @override
  String get balanceThisMonth => 'This Month Balance';

  @override
  String get thisMonth => 'This Month';

  @override
  String get today => 'Today';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get addTransaction => 'Add Record';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get amount => 'Amount';

  @override
  String get note => 'Note (optional, auto-categorize)';

  @override
  String get date => 'Date';

  @override
  String get category => 'Category';

  @override
  String get typeLabel => 'Type';

  @override
  String get recordTime => 'Record Time';

  @override
  String get noRecords => 'No records yet';

  @override
  String get tapToStart => 'Tap + to start';

  @override
  String get noMonthlyRecords => 'No records this month';

  @override
  String get noYearlyRecords => 'No records this year';

  @override
  String get loadFailed => 'Failed to load';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterPositiveAmount => 'Amount must be greater than 0';

  @override
  String get budget => 'Budget';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get categoryBudget => 'Category Budget';

  @override
  String categoryBudgetLabel(String category) {
    return '$category Budget';
  }

  @override
  String get notSet => 'Not set';

  @override
  String get overBudget => 'Over budget!';

  @override
  String get nearBudget => 'Near budget limit';

  @override
  String get budgetInputHint => 'Enter amount (clear to remove budget)';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get categoryManagement => 'Category Management';

  @override
  String get budgetSettings => 'Budget Settings';

  @override
  String get followSystem => 'Follow System';

  @override
  String get lightMode => 'Light';

  @override
  String get darkMode => 'Dark';

  @override
  String get searchTransactions => 'Search transactions';

  @override
  String get noResults => 'No results found';

  @override
  String get searchHint => 'Enter keyword to search';

  @override
  String get last6MonthsTrend => 'Last 6 Months Trend';

  @override
  String get noData => 'No data';

  @override
  String get totalLabel => 'Total';

  @override
  String get noMonthlyExpenseRecords => 'No expense records this month';

  @override
  String get noMonthlyIncomeRecords => 'No income records this month';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String confirmDeleteCategoryMsg(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get noCategoryYet => 'No categories yet';

  @override
  String get defaultLabel => 'Default';

  @override
  String get categoryName => 'Category Name';

  @override
  String get iconLabel => 'Icon';

  @override
  String get colorLabel => 'Color';

  @override
  String get customColor => 'Custom Color';

  @override
  String get addExpenseCategory => 'Add Expense Category';

  @override
  String get addIncomeCategory => 'Add Income Category';

  @override
  String get unknownCategory => 'Unknown';

  @override
  String get confirmCurrencyConvert => 'Change currency?';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get currencyConvertWarning =>
      'Existing amounts are not converted — only the currency symbol changes.';

  @override
  String get confirmConvert => 'Confirm';

  @override
  String get curUSD => 'US Dollar';

  @override
  String get curSGD => 'Singapore Dollar';

  @override
  String get curMYR => 'Malaysian Ringgit';

  @override
  String get curCNY => 'Chinese Yuan';

  @override
  String get curJPY => 'Japanese Yen';

  @override
  String get curEUR => 'Euro';

  @override
  String get curGBP => 'British Pound';

  @override
  String get curKRW => 'South Korean Won';

  @override
  String get curTHB => 'Thai Baht';

  @override
  String get curINR => 'Indian Rupee';

  @override
  String get curTWD => 'New Taiwan Dollar';

  @override
  String get curHKD => 'Hong Kong Dollar';

  @override
  String get curRegionUSD => 'United States';

  @override
  String get curRegionSGD => 'Singapore';

  @override
  String get curRegionMYR => 'Malaysia';

  @override
  String get curRegionCNY => 'China';

  @override
  String get curRegionJPY => 'Japan';

  @override
  String get curRegionEUR => 'Europe';

  @override
  String get curRegionGBP => 'United Kingdom';

  @override
  String get curRegionKRW => 'South Korea';

  @override
  String get curRegionTHB => 'Thailand';

  @override
  String get curRegionINR => 'India';

  @override
  String get curRegionTWD => 'Taiwan';

  @override
  String get curRegionHKD => 'Hong Kong';

  @override
  String get catFood => 'Food & Dining';

  @override
  String get catTransport => 'Transport';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catHealth => 'Healthcare';

  @override
  String get catBills => 'Bills';

  @override
  String get catOtherExpense => 'Other';

  @override
  String get catSalary => 'Salary';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catInvestment => 'Investment';

  @override
  String get catOtherIncome => 'Other Income';

  @override
  String get account => 'Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Register';

  @override
  String get skipLogin => 'Skip';

  @override
  String get checkEmailConfirmation =>
      'Registration successful! Check your email to confirm your account.';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get syncSuccess => 'Sync successful';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get signOut => 'Sign Out';

  @override
  String get loginForSync => 'Sign in to sync across devices';

  @override
  String get accountAndData => 'Account & Data';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetData => 'Reset Data';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get confirmDelete => 'This cannot be undone.';

  @override
  String get typeDeleteToConfirm => 'Type DELETE to confirm';

  @override
  String get settingsReset => 'Settings have been reset';

  @override
  String get dataReset => 'All records cleared';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get resetPasswordEmailSent => 'Reset email sent. Check your inbox.';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordUpdated => 'Password updated successfully';

  @override
  String get incorrectCurrentPassword =>
      'Incorrect current password, please try again';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get accounts => 'Accounts';

  @override
  String get accountLabel => 'Account';

  @override
  String get addAccount => 'Add Account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get accountName => 'Account Name';

  @override
  String get setAsDefaultAccount => 'Set as default';

  @override
  String get unassignedAccount => 'Unassigned';

  @override
  String get noAccountYet => 'No accounts yet';

  @override
  String get accountType => 'Account Type';

  @override
  String get acctCash => 'Cash';

  @override
  String get acctBank => 'Bank';

  @override
  String get acctCreditCard => 'Credit Card';

  @override
  String get acctEWallet => 'E-Wallet';

  @override
  String get acctSavings => 'Savings';

  @override
  String get openingBalance => 'Opening Balance';

  @override
  String get amountOwed => 'Amount Owed';

  @override
  String get duplicateAccountName => 'An account with this name already exists';

  @override
  String get transfer => 'Transfer';

  @override
  String get catTransfer => 'Transfer';

  @override
  String get fromAccount => 'From Account';

  @override
  String get toAccount => 'To Account';

  @override
  String get needTwoAccountsForTransfer =>
      'Create at least two accounts to transfer between them';

  @override
  String get sameAccountTransfer => 'Pick two different accounts';
}
