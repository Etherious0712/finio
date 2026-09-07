import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import 'package:finio/core/theme/app_theme.dart';
import 'package:finio/features/budget/budget_screen.dart';
import 'package:finio/shared/providers/database_provider.dart';

/// Drives budget creation and deletion through the real screen — the list is
/// user-managed now, so "can I actually add one" is the whole feature.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget host() => ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const BudgetScreen(),
        ),
      );

  Future<void> usePhoneScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  /// Unmount and flush drift's deferred stream-close timer.
  Future<void> settle(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  testWidgets('create a weekly overall budget through the sheet',
      (tester) async {
    await usePhoneScreen(tester);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    // Nothing is listed until the user makes one.
    expect(find.text('No budgets yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Weekly'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '500');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    final budget = (await db.budgetDao.getBudgets()).single;
    expect(budget.category, isNull); // "Overall Budget" is the default pick
    expect(budget.period, 'week');
    expect(budget.amount, 500);
    expect(budget.overrideAmount, isNull);

    expect(find.text('Overall Budget'), findsOneWidget);
    expect(find.text('Weekly'), findsOneWidget);

    await settle(tester);
  });

  testWidgets('the override control only exists for a monthly budget',
      (tester) async {
    await usePhoneScreen(tester);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    // Monthly is the default period.
    expect(find.text('Override one month'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Yearly'));
    await tester.pumpAndSettle();
    expect(find.text('Override one month'), findsNothing);

    await settle(tester);
  });

  testWidgets('delete removes the budget after confirming', (tester) async {
    await usePhoneScreen(tester);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '300');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect((await db.budgetDao.getBudgets()).length, 1);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(await db.budgetDao.getBudgets(), isEmpty);
    expect(find.text('No budgets yet'), findsOneWidget);

    await settle(tester);
  });
}
