import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_localizations.dart';

import 'core/notifications/budget_notifier.dart';
import 'core/sync/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/budget/budget_screen.dart';
import 'features/categories/category_management_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/settings/account_data_screen.dart';
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
        GoRoute(
          path: 'account-data',
          builder: (context, state) => const AccountDataScreen(),
        ),
        GoRoute(
          path: 'auth',
          builder: (context, state) => const AuthScreen(),
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
  // Only Dashboard is rendered on the first frame.
  // Other tabs are built lazily on first visit, after localization is ready.
  final Set<int> _loadedTabs = {0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkBudgetOnStartup();
      await ref.read(syncServiceProvider).syncAll();
    });
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

  void _switchTo(int i) {
    setState(() {
      _index = i;
      _loadedTabs.add(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const DashboardScreen(),
          _loadedTabs.contains(1)
              ? const TransactionListScreen()
              : const SizedBox.shrink(),
          _loadedTabs.contains(2)
              ? const StatisticsScreen()
              : const SizedBox.shrink(),
          _loadedTabs.contains(3)
              ? const SettingsScreen()
              : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _switchTo,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l.transactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l.statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l.settings,
          ),
        ],
      ),
    );
  }
}
