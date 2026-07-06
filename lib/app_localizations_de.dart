// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get spendingTrend => 'Ausgabentrend';

  @override
  String get totalBalance => 'Gesamtsaldo';

  @override
  String get editTransaction => 'Eintrag bearbeiten';

  @override
  String get groupByMonth => 'Nach Monat';

  @override
  String get groupByYear => 'Nach Jahr';

  @override
  String get groupByCategory => 'Nach Kategorie';

  @override
  String get allTime => 'Gesamter Zeitraum';

  @override
  String get vsLastMonth => 'ggü. Vormonat';

  @override
  String get recordsUsed => 'Einträge';

  @override
  String get editCategory => 'Kategorie bearbeiten';

  @override
  String get appName => 'Finio';

  @override
  String get dashboard => 'Startseite';

  @override
  String get transactions => 'Einträge';

  @override
  String get statistics => 'Statistiken';

  @override
  String get settings => 'Einstellungen';

  @override
  String get income => 'Einnahmen';

  @override
  String get expense => 'Ausgaben';

  @override
  String get balance => 'Saldo';

  @override
  String get balanceThisMonth => 'Monatlicher Saldo';

  @override
  String get thisMonth => 'Diesen Monat';

  @override
  String get today => 'Heute';

  @override
  String get recentTransactions => 'Letzte Transaktionen';

  @override
  String get addTransaction => 'Eintrag hinzufügen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get amount => 'Betrag';

  @override
  String get note => 'Notiz (optional, auto-kategorisiert)';

  @override
  String get date => 'Datum';

  @override
  String get category => 'Kategorie';

  @override
  String get typeLabel => 'Typ';

  @override
  String get recordTime => 'Aufzeichnungszeit';

  @override
  String get noRecords => 'Noch keine Einträge';

  @override
  String get tapToStart => 'Tippe auf + um zu starten';

  @override
  String get noMonthlyRecords => 'Keine Einträge diesen Monat';

  @override
  String get noYearlyRecords => 'Keine Einträge dieses Jahr';

  @override
  String get loadFailed => 'Laden fehlgeschlagen';

  @override
  String get pleaseSelectCategory => 'Bitte Kategorie auswählen';

  @override
  String get pleaseEnterAmount => 'Bitte Betrag eingeben';

  @override
  String get pleaseEnterPositiveAmount => 'Betrag muss größer als 0 sein';

  @override
  String get budget => 'Budget';

  @override
  String get monthlyBudget => 'Monatsbudget';

  @override
  String get categoryBudget => 'Kategoriebudget';

  @override
  String categoryBudgetLabel(String category) {
    return 'Budget $category';
  }

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get overBudget => '❌ Überschritten!';

  @override
  String get nearBudget => '⚠️ Nahe der Grenze';

  @override
  String get budgetInputHint => 'Betrag eingeben (leer lassen zum Löschen)';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get language => 'Sprache';

  @override
  String get currency => 'Währung';

  @override
  String get categoryManagement => 'Kategorieverwaltung';

  @override
  String get budgetSettings => 'Budgeteinstellungen';

  @override
  String get followSystem => 'System folgen';

  @override
  String get lightMode => 'Hell';

  @override
  String get darkMode => 'Dunkel';

  @override
  String get searchTransactions => 'Transaktionen suchen';

  @override
  String get noResults => 'Keine Ergebnisse';

  @override
  String get searchHint => 'Schlüsselwort eingeben';

  @override
  String get last6MonthsTrend => 'Trend der letzten 6 Monate';

  @override
  String get noData => 'Keine Daten';

  @override
  String get totalLabel => 'Gesamt';

  @override
  String get noMonthlyExpenseRecords => 'Keine Ausgaben diesen Monat';

  @override
  String get noMonthlyIncomeRecords => 'Keine Einnahmen diesen Monat';

  @override
  String get deleteCategory => 'Kategorie löschen';

  @override
  String confirmDeleteCategoryMsg(String name) {
    return '\"$name\" löschen?';
  }

  @override
  String get noCategoryYet => 'Noch keine Kategorien';

  @override
  String get defaultLabel => 'Standard';

  @override
  String get categoryName => 'Kategoriename';

  @override
  String get iconLabel => 'Symbol';

  @override
  String get colorLabel => 'Farbe';

  @override
  String get customColor => 'Benutzerdefinierte Farbe';

  @override
  String get addExpenseCategory => 'Ausgabenkategorie hinzufügen';

  @override
  String get addIncomeCategory => 'Einnahmenkategorie hinzufügen';

  @override
  String get unknownCategory => 'Unbekannt';

  @override
  String get confirmCurrencyConvert => 'Währungsumrechnung bestätigen?';

  @override
  String get fromLabel => 'Von';

  @override
  String get toLabel => 'Nach';

  @override
  String get currencyConvertWarning =>
      'Alle Beträge werden zum aktuellen Kurs umgerechnet. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get confirmConvert => 'Bestätigen';

  @override
  String currencyConvertSuccess(int count) {
    return 'Umrechnung abgeschlossen, $count Einträge aktualisiert';
  }

  @override
  String get currencyNotSupported =>
      'Diese Währung wird von Frankfurter nicht unterstützt';

  @override
  String get exchangeRateFetchFailed =>
      'Wechselkurs konnte nicht abgerufen werden. Bitte Verbindung prüfen.';

  @override
  String get catFood => 'Essen & Trinken';

  @override
  String get catTransport => 'Transport';

  @override
  String get catShopping => 'Einkaufen';

  @override
  String get catEntertainment => 'Unterhaltung';

  @override
  String get catHealth => 'Gesundheit';

  @override
  String get catBills => 'Rechnungen';

  @override
  String get catOtherExpense => 'Sonstiges';

  @override
  String get catSalary => 'Gehalt';

  @override
  String get catFreelance => 'Freiberuflich';

  @override
  String get catInvestment => 'Investitionen';

  @override
  String get catOtherIncome => 'Sonstige Einnahmen';

  @override
  String get account => 'Konto';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get skipLogin => 'Überspringen';

  @override
  String get checkEmailConfirmation =>
      'Registrierung erfolgreich! Überprüfen Sie Ihre E-Mail zur Kontobestätigung.';

  @override
  String get cloudSync => 'Cloud-Synchronisierung';

  @override
  String get syncSuccess => 'Synchronisierung erfolgreich';

  @override
  String get syncFailed => 'Synchronisierung fehlgeschlagen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get loginForSync =>
      'Anmelden zur geräteübergreifenden Synchronisierung';

  @override
  String get accountAndData => 'Konto & Daten';

  @override
  String get resetSettings => 'Einstellungen zurücksetzen';

  @override
  String get resetData => 'Daten zurücksetzen';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get forgotPassword => 'Passwort vergessen';

  @override
  String get dangerZone => 'Gefahrenzone';

  @override
  String get confirmDelete =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get typeDeleteToConfirm => 'Geben Sie DELETE ein zur Bestätigung';

  @override
  String get settingsReset => 'Einstellungen zurückgesetzt';

  @override
  String get dataReset => 'Alle Einträge gelöscht';

  @override
  String get accountDeleted => 'Konto gelöscht';

  @override
  String get resetPasswordEmailSent =>
      'Passwort-Reset-E-Mail gesendet. Bitte prüfen Sie Ihren Posteingang.';

  @override
  String get dataManagement => 'Datenverwaltung';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get currentPassword => 'Aktuelles Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get confirmNewPassword => 'Neues Passwort bestätigen';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordUpdated => 'Passwort erfolgreich aktualisiert';

  @override
  String get incorrectCurrentPassword =>
      'Aktuelles Passwort falsch, bitte erneut versuchen';

  @override
  String get passwordTooShort =>
      'Das Passwort muss mindestens 6 Zeichen lang sein';
}
