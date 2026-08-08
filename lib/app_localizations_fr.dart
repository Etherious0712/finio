// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get spendingTrend => 'Tendance des dépenses';

  @override
  String get totalBalance => 'Solde total';

  @override
  String get editTransaction => 'Modifier l\'entrée';

  @override
  String get groupByMonth => 'Par mois';

  @override
  String get groupByYear => 'Par année';

  @override
  String get groupByCategory => 'Par catégorie';

  @override
  String get allTime => 'Tout l\'historique';

  @override
  String get vsLastMonth => 'vs mois dernier';

  @override
  String get recordsUsed => 'entrées';

  @override
  String get editCategory => 'Modifier la catégorie';

  @override
  String get appName => 'Finio';

  @override
  String get dashboard => 'Accueil';

  @override
  String get transactions => 'Dossiers';

  @override
  String get statistics => 'Statistiques';

  @override
  String get settings => 'Paramètres';

  @override
  String get income => 'Revenus';

  @override
  String get expense => 'Dépenses';

  @override
  String get balance => 'Solde';

  @override
  String get balanceThisMonth => 'Solde du mois';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get recentTransactions => 'Transactions récentes';

  @override
  String get addTransaction => 'Ajouter';

  @override
  String get save => 'Sauvegarder';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get amount => 'Montant';

  @override
  String get note => 'Note (facultatif, auto-catégorie)';

  @override
  String get date => 'Date';

  @override
  String get category => 'Catégorie';

  @override
  String get typeLabel => 'Type';

  @override
  String get recordTime => 'Heure d\'enregistrement';

  @override
  String get noRecords => 'Aucun enregistrement';

  @override
  String get tapToStart => 'Appuyez sur + pour commencer';

  @override
  String get noMonthlyRecords => 'Aucun enregistrement ce mois';

  @override
  String get noYearlyRecords => 'Aucun enregistrement cette année';

  @override
  String get loadFailed => 'Échec du chargement';

  @override
  String get pleaseSelectCategory => 'Veuillez sélectionner une catégorie';

  @override
  String get pleaseEnterAmount => 'Veuillez entrer un montant';

  @override
  String get pleaseEnterPositiveAmount => 'Le montant doit être supérieur à 0';

  @override
  String get budget => 'Budget';

  @override
  String get monthlyBudget => 'Budget mensuel';

  @override
  String get categoryBudget => 'Budget par catégorie';

  @override
  String categoryBudgetLabel(String category) {
    return 'Budget $category';
  }

  @override
  String get notSet => 'Non défini';

  @override
  String get overBudget => '❌ Dépassement!';

  @override
  String get nearBudget => '⚠️ Proche de la limite';

  @override
  String get budgetInputHint => 'Entrez le montant (vide pour supprimer)';

  @override
  String get appearance => 'Apparence';

  @override
  String get language => 'Langue';

  @override
  String get currency => 'Devise';

  @override
  String get categoryManagement => 'Gestion des catégories';

  @override
  String get budgetSettings => 'Paramètres de budget';

  @override
  String get followSystem => 'Suivre le système';

  @override
  String get lightMode => 'Clair';

  @override
  String get darkMode => 'Sombre';

  @override
  String get searchTransactions => 'Rechercher des transactions';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String get searchHint => 'Saisissez un mot-clé';

  @override
  String get last6MonthsTrend => 'Tendance des 6 derniers mois';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get totalLabel => 'Total';

  @override
  String get noMonthlyExpenseRecords => 'Aucune dépense ce mois';

  @override
  String get noMonthlyIncomeRecords => 'Aucun revenu ce mois';

  @override
  String get deleteCategory => 'Supprimer la catégorie';

  @override
  String confirmDeleteCategoryMsg(String name) {
    return 'Supprimer \"$name\" ?';
  }

  @override
  String get noCategoryYet => 'Aucune catégorie';

  @override
  String get defaultLabel => 'Par défaut';

  @override
  String get categoryName => 'Nom de catégorie';

  @override
  String get iconLabel => 'Icône';

  @override
  String get colorLabel => 'Couleur';

  @override
  String get customColor => 'Couleur personnalisée';

  @override
  String get addExpenseCategory => 'Ajouter une catégorie de dépense';

  @override
  String get addIncomeCategory => 'Ajouter une catégorie de revenu';

  @override
  String get unknownCategory => 'Inconnu';

  @override
  String get confirmCurrencyConvert => 'Confirmer la conversion de devise ?';

  @override
  String get fromLabel => 'De';

  @override
  String get toLabel => 'À';

  @override
  String get currencyConvertWarning =>
      'Tous les montants seront convertis à ce taux. Cette opération est irréversible.';

  @override
  String get confirmConvert => 'Confirmer';

  @override
  String currencyConvertSuccess(int count) {
    return 'Conversion terminée, $count enregistrements mis à jour';
  }

  @override
  String get currencyNotSupported =>
      'Cette devise n\'est pas supportée par Frankfurter';

  @override
  String get exchangeRateFetchFailed =>
      'Impossible d\'obtenir le taux. Vérifiez votre connexion.';

  @override
  String get catFood => 'Alimentation';

  @override
  String get catTransport => 'Transport';

  @override
  String get catShopping => 'Achats';

  @override
  String get catEntertainment => 'Divertissement';

  @override
  String get catHealth => 'Santé';

  @override
  String get catBills => 'Factures';

  @override
  String get catOtherExpense => 'Autre';

  @override
  String get catSalary => 'Salaire';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catInvestment => 'Investissement';

  @override
  String get catOtherIncome => 'Autre revenu';

  @override
  String get account => 'Compte';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get skipLogin => 'Ignorer';

  @override
  String get checkEmailConfirmation =>
      'Inscription réussie ! Vérifiez votre e-mail pour confirmer votre compte.';

  @override
  String get cloudSync => 'Synchronisation Cloud';

  @override
  String get syncSuccess => 'Synchronisation réussie';

  @override
  String get syncFailed => 'Échec de la synchronisation';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get loginForSync =>
      'Connectez-vous pour synchroniser entre les appareils';

  @override
  String get accountAndData => 'Compte et données';

  @override
  String get resetSettings => 'Réinitialiser les paramètres';

  @override
  String get resetData => 'Réinitialiser les données';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get dangerZone => 'Zone dangereuse';

  @override
  String get confirmDelete => 'Cette action est irréversible.';

  @override
  String get typeDeleteToConfirm => 'Tapez DELETE pour confirmer';

  @override
  String get settingsReset => 'Paramètres réinitialisés';

  @override
  String get dataReset => 'Tous les enregistrements supprimés';

  @override
  String get accountDeleted => 'Compte supprimé';

  @override
  String get resetPasswordEmailSent =>
      'E-mail de réinitialisation envoyé. Vérifiez votre boîte de réception.';

  @override
  String get dataManagement => 'Gestion des données';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordUpdated => 'Mot de passe mis à jour avec succès';

  @override
  String get incorrectCurrentPassword =>
      'Mot de passe actuel incorrect, veuillez réessayer';

  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get savingsAccounts => 'Comptes d\'épargne';

  @override
  String get savingsAccount => 'Compte d\'épargne';

  @override
  String get addSavingsAccount => 'Ajouter un compte d\'épargne';

  @override
  String get editSavingsAccount => 'Modifier le compte d\'épargne';

  @override
  String get savingsAccountName => 'Nom du compte';

  @override
  String get setAsDefaultAccount => 'Définir par défaut';

  @override
  String get unassignedAccount => 'Non attribué';

  @override
  String get noAccountYet => 'Aucun compte d\'épargne';

  @override
  String get currentRateLabel => 'Taux actuel';

  @override
  String get rateSourceLabel => 'Source';
}
