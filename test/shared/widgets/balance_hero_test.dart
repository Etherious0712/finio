import 'package:finio/app_localizations.dart';
import 'package:finio/core/theme/app_theme.dart';
import 'package:finio/shared/widgets/balance_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The hide-amounts toggle is a privacy control, so it gets a test: a leak here
/// is the whole point of the feature failing.
void main() {
  Widget host({required bool hidden, double total = 1234.56}) => MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: BalanceHero(
            totalBalance: total,
            monthlyIncome: 2000,
            monthlyExpense: 765.43,
            todayIncome: 10,
            todayExpense: 20,
            symbol: r'$',
            currencyCode: 'USD',
            hidden: hidden,
            onHiddenChanged: (_) {},
          ),
        ),
      );

  testWidgets('shows every amount when not hidden', (tester) async {
    await tester.pumpWidget(host(hidden: false));
    expect(find.text(r'$1,234.56'), findsOneWidget);
    expect(find.text('2,000.00'), findsOneWidget);
    expect(find.text('765.43'), findsOneWidget);
    expect(find.text('••••'), findsNothing);
  });

  testWidgets('masks all five numbers when hidden', (tester) async {
    await tester.pumpWidget(host(hidden: true));
    expect(find.text('••••'), findsNWidgets(5));
    // No digit from any of the five may survive anywhere on the card.
    for (final leak in ['1,234', '2,000', '765', '10.00', '20.00']) {
      expect(find.textContaining(leak), findsNothing, reason: 'leaked $leak');
    }
    // The currency code is not an amount and stays.
    expect(find.text('USD'), findsOneWidget);
  });

  testWidgets('a hidden negative balance does not leak its sign', (tester) async {
    await tester.pumpWidget(host(hidden: true, total: -500));
    final container = tester.widget<Container>(find
        .descendant(of: find.byType(BalanceHero), matching: find.byType(Container))
        .first);
    final gradient =
        (container.decoration as BoxDecoration).gradient as LinearGradient;
    // Same gradient a positive balance gets — the red one would give it away.
    await tester.pumpWidget(host(hidden: true, total: 500));
    final positive = tester.widget<Container>(find
        .descendant(of: find.byType(BalanceHero), matching: find.byType(Container))
        .first);
    expect(gradient.colors,
        ((positive.decoration as BoxDecoration).gradient as LinearGradient).colors);
  });
}
