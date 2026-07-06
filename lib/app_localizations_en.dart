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
  String get confirmCurrencyConvert => 'Confirm currency conversion?';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get currencyConvertWarning =>
      'All transaction amounts will be converted at this rate. This cannot be undone.';

  @override
  String get confirmConvert => 'Confirm';

  @override
  String currencyConvertSuccess(int count) {
    return 'Conversion complete, updated $count records';
  }

  @override
  String get currencyNotSupported =>
      'This currency is not supported by Frankfurter';

  @override
  String get exchangeRateFetchFailed =>
      'Failed to fetch exchange rate. Please check your connection.';

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
}
