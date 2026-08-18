import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'lib/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('zh'),
  ];

  /// No description provided for @spendingTrend.
  ///
  /// In en, this message translates to:
  /// **'Spending Trend'**
  String get spendingTrend;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Record'**
  String get editTransaction;

  /// No description provided for @groupByMonth.
  ///
  /// In en, this message translates to:
  /// **'By Month'**
  String get groupByMonth;

  /// No description provided for @groupByYear.
  ///
  /// In en, this message translates to:
  /// **'By Year'**
  String get groupByYear;

  /// No description provided for @groupByCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get groupByCategory;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs last month'**
  String get vsLastMonth;

  /// No description provided for @recordsUsed.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get recordsUsed;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Finio'**
  String get appName;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get transactions;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @balanceThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month Balance'**
  String get balanceThisMonth;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get addTransaction;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note (optional, auto-categorize)'**
  String get note;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @recordTime.
  ///
  /// In en, this message translates to:
  /// **'Record Time'**
  String get recordTime;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecords;

  /// No description provided for @tapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap + to start'**
  String get tapToStart;

  /// No description provided for @noMonthlyRecords.
  ///
  /// In en, this message translates to:
  /// **'No records this month'**
  String get noMonthlyRecords;

  /// No description provided for @noYearlyRecords.
  ///
  /// In en, this message translates to:
  /// **'No records this year'**
  String get noYearlyRecords;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get loadFailed;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseEnterPositiveAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get pleaseEnterPositiveAmount;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @categoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Category Budget'**
  String get categoryBudget;

  /// No description provided for @categoryBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'{category} Budget'**
  String categoryBudgetLabel(String category);

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget!'**
  String get overBudget;

  /// No description provided for @nearBudget.
  ///
  /// In en, this message translates to:
  /// **'Near budget limit'**
  String get nearBudget;

  /// No description provided for @budgetInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount (clear to remove budget)'**
  String get budgetInputHint;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagement;

  /// No description provided for @budgetSettings.
  ///
  /// In en, this message translates to:
  /// **'Budget Settings'**
  String get budgetSettings;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get searchTransactions;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Enter keyword to search'**
  String get searchHint;

  /// No description provided for @last6MonthsTrend.
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months Trend'**
  String get last6MonthsTrend;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @noMonthlyExpenseRecords.
  ///
  /// In en, this message translates to:
  /// **'No expense records this month'**
  String get noMonthlyExpenseRecords;

  /// No description provided for @noMonthlyIncomeRecords.
  ///
  /// In en, this message translates to:
  /// **'No income records this month'**
  String get noMonthlyIncomeRecords;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @confirmDeleteCategoryMsg.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String confirmDeleteCategoryMsg(String name);

  /// No description provided for @noCategoryYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoryYet;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom Color'**
  String get customColor;

  /// No description provided for @addExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Expense Category'**
  String get addExpenseCategory;

  /// No description provided for @addIncomeCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Income Category'**
  String get addIncomeCategory;

  /// No description provided for @unknownCategory.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownCategory;

  /// No description provided for @confirmCurrencyConvert.
  ///
  /// In en, this message translates to:
  /// **'Change currency?'**
  String get confirmCurrencyConvert;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @currencyConvertWarning.
  ///
  /// In en, this message translates to:
  /// **'Existing amounts are not converted — only the currency symbol changes.'**
  String get currencyConvertWarning;

  /// No description provided for @confirmConvert.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmConvert;

  /// No description provided for @curUSD.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get curUSD;

  /// No description provided for @curSGD.
  ///
  /// In en, this message translates to:
  /// **'Singapore Dollar'**
  String get curSGD;

  /// No description provided for @curMYR.
  ///
  /// In en, this message translates to:
  /// **'Malaysian Ringgit'**
  String get curMYR;

  /// No description provided for @curCNY.
  ///
  /// In en, this message translates to:
  /// **'Chinese Yuan'**
  String get curCNY;

  /// No description provided for @curJPY.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get curJPY;

  /// No description provided for @curEUR.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get curEUR;

  /// No description provided for @curGBP.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get curGBP;

  /// No description provided for @curKRW.
  ///
  /// In en, this message translates to:
  /// **'South Korean Won'**
  String get curKRW;

  /// No description provided for @curTHB.
  ///
  /// In en, this message translates to:
  /// **'Thai Baht'**
  String get curTHB;

  /// No description provided for @curINR.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee'**
  String get curINR;

  /// No description provided for @curTWD.
  ///
  /// In en, this message translates to:
  /// **'New Taiwan Dollar'**
  String get curTWD;

  /// No description provided for @curHKD.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Dollar'**
  String get curHKD;

  /// No description provided for @curRegionUSD.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get curRegionUSD;

  /// No description provided for @curRegionSGD.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get curRegionSGD;

  /// No description provided for @curRegionMYR.
  ///
  /// In en, this message translates to:
  /// **'Malaysia'**
  String get curRegionMYR;

  /// No description provided for @curRegionCNY.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get curRegionCNY;

  /// No description provided for @curRegionJPY.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get curRegionJPY;

  /// No description provided for @curRegionEUR.
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get curRegionEUR;

  /// No description provided for @curRegionGBP.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get curRegionGBP;

  /// No description provided for @curRegionKRW.
  ///
  /// In en, this message translates to:
  /// **'South Korea'**
  String get curRegionKRW;

  /// No description provided for @curRegionTHB.
  ///
  /// In en, this message translates to:
  /// **'Thailand'**
  String get curRegionTHB;

  /// No description provided for @curRegionINR.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get curRegionINR;

  /// No description provided for @curRegionTWD.
  ///
  /// In en, this message translates to:
  /// **'Taiwan'**
  String get curRegionTWD;

  /// No description provided for @curRegionHKD.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong'**
  String get curRegionHKD;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get catFood;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get catHealth;

  /// No description provided for @catBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get catBills;

  /// No description provided for @catOtherExpense.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOtherExpense;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get catFreelance;

  /// No description provided for @catInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get catInvestment;

  /// No description provided for @catOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other Income'**
  String get catOtherIncome;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get signUp;

  /// No description provided for @skipLogin.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipLogin;

  /// No description provided for @checkEmailConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Check your email to confirm your account.'**
  String get checkEmailConfirmation;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync successful'**
  String get syncSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @loginForSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync across devices'**
  String get loginForSync;

  /// No description provided for @accountAndData.
  ///
  /// In en, this message translates to:
  /// **'Account & Data'**
  String get accountAndData;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetData;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get confirmDelete;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get typeDeleteToConfirm;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Settings have been reset'**
  String get settingsReset;

  /// No description provided for @dataReset.
  ///
  /// In en, this message translates to:
  /// **'All records cleared'**
  String get dataReset;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @resetPasswordEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent. Check your inbox.'**
  String get resetPasswordEmailSent;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @incorrectCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect current password, please try again'**
  String get incorrectCurrentPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @setAsDefaultAccount.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefaultAccount;

  /// No description provided for @unassignedAccount.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassignedAccount;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccountYet;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @acctCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get acctCash;

  /// No description provided for @acctBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get acctBank;

  /// No description provided for @acctCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get acctCreditCard;

  /// No description provided for @acctEWallet.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet'**
  String get acctEWallet;

  /// No description provided for @acctSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get acctSavings;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get openingBalance;

  /// No description provided for @amountOwed.
  ///
  /// In en, this message translates to:
  /// **'Amount Owed'**
  String get amountOwed;

  /// No description provided for @duplicateAccountName.
  ///
  /// In en, this message translates to:
  /// **'An account with this name already exists'**
  String get duplicateAccountName;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @catTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get catTransfer;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get toAccount;

  /// No description provided for @needTwoAccountsForTransfer.
  ///
  /// In en, this message translates to:
  /// **'Create at least two accounts to transfer between them'**
  String get needTwoAccountsForTransfer;

  /// No description provided for @sameAccountTransfer.
  ///
  /// In en, this message translates to:
  /// **'Pick two different accounts'**
  String get sameAccountTransfer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'ms',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
