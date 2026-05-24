import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_localizations.dart';

import 'core/notifications/budget_notifier.dart';
import 'core/theme/app_theme.dart';
import 'features/budget/budget_screen.dart';
import 'features/categories/category_management_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/settings/appearance_screen.dart';
import 'features/settings/currency_screen.dart';
import 'features/settings/language_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/statistics/statistics_screen.dart';
import 'features/transactions/add_transaction_screen.dart';
import 'features/transactions/search_screen.dart';
import 'features/transactions/transaction_list_screen.dart';
import 'shared/providers/database_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/transaction_providers.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
      routes: [
        GoRoute(
          path: 'transactions/add',
          builder: (context, state) => const AddTransactionScreen(),
        ),
        GoRoute(
          path: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: 'categories',
          builder: (context, state) => const CategoryManagementScreen(),
        ),
        GoRoute(
          path: 'budget',
          builder: (context, state) => const BudgetScreen(),
        ),
        GoRoute(
          path: 'appearance',
          builder: (context, state) => const AppearanceScreen(),
        ),
        GoRoute(
          path: 'currency',
          builder: (context, state) => const CurrencyScreen(),
        ),
        GoRoute(
          path: 'language',
          builder: (context, state) => const LanguageScreen(),
        ),
      ],
    ),
  ],
);

class FinioApp extends ConsumerWidget {
  const FinioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Finio',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (appThemeMode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      routerConfig: _router,
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBudgetOnStartup());
  }

  Future<void> _checkBudgetOnStartup() async {
    if (!mounted) return;
    final db = ref.read(appDatabaseProvider);
    final month = ref.read(selectedMonthProvider);
    final budget = await db.budgetDao.getOverallBudget();
    final totals =
        await db.transactionDao.getMonthlyTotals(month.year, month.month);
    await BudgetNotifier.checkAndNotify(
      expense: totals['expense'] ?? 0.0,
      budget: budget?.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          TransactionListScreen(),
          StatisticsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: AppLocalizations.of(context)!.transactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: AppLocalizations.of(context)!.statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}
