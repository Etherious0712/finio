import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/ai/rule_classifier.dart' show TransactionType;
import 'package:finio/core/database/app_database.dart';
import 'package:finio/core/theme/app_theme.dart';
import 'package:finio/features/accounts/account_management_screen.dart';
import 'package:finio/features/statistics/statistics_screen.dart';
import 'package:finio/features/transactions/add_transaction_screen.dart';
import 'package:finio/shared/providers/database_provider.dart';
import 'package:finio/shared/widgets/quick_add_sheet.dart';

/// Drives the savings-jar feature through the real screens against a real
/// in-memory database — the jar picker, the sheet, and the insert path are the
/// production widgets, not stand-ins.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Wraps [child] with the app's real theme + localizations, and a GoRouter
  /// whose stack has a parent route so screens calling `context.pop()` behave
  /// as they do in the app.
  Widget host(Widget child) => ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: GoRouter(
            initialLocation: '/screen',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const SizedBox.shrink(),
                routes: [
                  GoRoute(path: 'screen', builder: (_, _) => child),
                ],
              ),
            ],
          ),
        ),
      );

  /// Phone-sized viewport — the default 800x600 test surface is nothing like the
  /// screen the entry sheet actually renders on.
  Future<void> usePhoneScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  /// Unmount and flush drift's deferred stream-close timer.
  Future<void> settle(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  /// Taps digits on the real keypad, pumping between each so the parent's
  /// rebuilt value is what the next tap appends to.
  Future<void> typeAmount(WidgetTester tester, String digits) async {
    for (final d in digits.split('')) {
      await tester.tap(find.widgetWithText(InkWell, d));
      await tester.pump();
    }
  }

  Future<int> seedJar(String name, {bool isDefault = false}) async {
    final id = await db.accountDao.insertAccount(
      AccountsCompanion.insert(name: name, icon: 'savings', color: '#42A5F5'),
    );
    if (isDefault) await db.accountDao.setDefault(id);
    return id;
  }

  testWidgets('create a jar through the management screen, marked default',
      (tester) async {
    await tester.pumpWidget(host(const AccountManagementScreen()));
    await tester.pumpAndSettle();

    // Empty state before any jar exists.
    expect(find.text('No savings accounts yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Account Name'), 'Maybank');
    await tester.tap(find.byType(SwitchListTile)); // set as default
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final jars = await db.accountDao.getAllAccounts();
    expect(jars.map((a) => a.name), ['Maybank']);
    expect(jars.single.isDefault, isTrue);
    expect(find.text('Maybank'), findsOneWidget);

    await settle(tester);
  });

  testWidgets('quick-add preselects the default jar and files the record there',
      (tester) async {
    await usePhoneScreen(tester);
    await seedJar('TNG eWallet', isDefault: true);
    await seedJar('Maybank');

    await tester.pumpWidget(host(
      // The sheet is normally shown modally; hosting it directly still runs the
      // real widget, picker and save path.
      const Material(
          child: QuickAddSheet(initialType: TransactionType.expense)),
    ));
    await tester.pumpAndSettle();

    // Both jars offered, plus the "unassigned" escape hatch.
    expect(find.text('TNG eWallet'), findsOneWidget);
    expect(find.text('Maybank'), findsOneWidget);
    expect(find.text('Unassigned'), findsOneWidget);

    // Type an amount on the real keypad, then save.
    await typeAmount(tester, '25');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final txs = await db.transactionDao.searchTransactions('');
    expect(txs.length, 1);
    expect(txs.single.amount, 25);
    // Default jar applied without the user touching the picker.
    expect(txs.single.account, 'TNG eWallet');

    await settle(tester);
  });

  testWidgets('quick-add honours switching to a non-default jar',
      (tester) async {
    await usePhoneScreen(tester);
    await seedJar('TNG eWallet', isDefault: true);
    await seedJar('Maybank');

    await tester.pumpWidget(host(
      const Material(
          child: QuickAddSheet(initialType: TransactionType.expense)),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Maybank'));
    await tester.pumpAndSettle();
    await typeAmount(tester, '7');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final txs = await db.transactionDao.searchTransactions('');
    expect(txs.single.account, 'Maybank');

    await settle(tester);
  });

  testWidgets('add screen preselects the default jar and saves it',
      (tester) async {
    await usePhoneScreen(tester);
    await seedJar('Maybank', isDefault: true);

    await tester.pumpWidget(host(const AddTransactionScreen()));
    await tester.pumpAndSettle();

    // The jar row sits below the category grid, so it takes a scroll to reach —
    // check it's actually reachable and preselected, not just stored.
    // .first = the screen's vertical body; the jar row has its own horizontal one.
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Maybank'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '40');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final txs = await db.transactionDao.searchTransactions('');
    expect(txs.single.account, 'Maybank');
    expect(txs.single.amount, 40);

    await settle(tester);
  });

  testWidgets('editing a record keeps its existing jar', (tester) async {
    await seedJar('Maybank', isDefault: true);
    await seedJar('TNG eWallet');
    await db.transactionDao.insertTransaction(TransactionsCompanion.insert(
      title: 'old',
      amount: 12,
      type: 'expense',
      category: 'catFood',
      date: DateTime(2024, 5, 1),
      account: const Value('TNG eWallet'),
    ));
    final existing = (await db.transactionDao.searchTransactions('')).single;

    await tester.pumpWidget(host(AddTransactionScreen(existing: existing)));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final after = (await db.transactionDao.searchTransactions('')).single;
    // The default jar must not hijack a record that already had one.
    expect(after.account, 'TNG eWallet');

    await settle(tester);
  });

  testWidgets('statistics lists per-jar net balance and a reconciling total',
      (tester) async {
    await seedJar('Maybank');
    await seedJar('TNG eWallet');

    Future<void> tx(String type, double amount, String? account) =>
        db.transactionDao.insertTransaction(TransactionsCompanion.insert(
          title: 't',
          amount: amount,
          type: type,
          category: type == 'income' ? 'catSalary' : 'catFood',
          date: DateTime.now(),
          account: Value(account),
        ));

    await tx('income', 1000, 'Maybank');
    await tx('expense', 250, 'Maybank');   // Maybank net  = 750
    await tx('expense', 80, 'TNG eWallet'); // eWallet net = -80
    await tx('expense', 20, null);          // unassigned  = -20

    await tester.pumpWidget(host(const StatisticsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Savings Accounts'), findsOneWidget);
    expect(find.text('Maybank'), findsOneWidget);
    expect(find.text('TNG eWallet'), findsOneWidget);
    expect(find.text('Unassigned'), findsOneWidget);

    // formatAmount prefixes the symbol, so negatives read "$-80.00" — same as
    // the dashboard's negative total balance today.
    expect(find.text('\$750.00'), findsOneWidget);
    expect(find.text('\$-80.00'), findsOneWidget);
    expect(find.text('\$-20.00'), findsOneWidget);
    // Total must reconcile with the dashboard's all-time balance: 750-80-20.
    expect(find.text('\$650.00'), findsOneWidget);

    await settle(tester);
  });

  testWidgets('renaming a jar through the UI carries its transactions',
      (tester) async {
    await seedJar('Maybank');
    await db.transactionDao.insertTransaction(TransactionsCompanion.insert(
      title: 'groceries',
      amount: 30,
      type: 'expense',
      category: 'catFood',
      date: DateTime(2024, 5, 1),
      account: const Value('Maybank'),
    ));

    await tester.pumpWidget(host(const AccountManagementScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Maybank'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Account Name'), 'Maybank Savings');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final txs = await db.transactionDao.searchTransactions('');
    expect(txs.single.account, 'Maybank Savings');

    await settle(tester);
  });
}
