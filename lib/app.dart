import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'app_localizations.dart';

import 'core/database/app_database.dart';
import 'core/notifications/budget_notifier.dart';
import 'core/sync/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/accounts/account_management_screen.dart';
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
import 'core/theme/app_motion.dart';
import 'shared/providers/database_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/navigation_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/transaction_providers.dart';
import 'shared/widgets/speed_dial_fab.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
      routes: [
        GoRoute(
          path: 'transactions/add',
          builder: (context, state) =>
              AddTransactionScreen(existing: state.extra as Transaction?),
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
          path: 'accounts',
          builder: (context, state) => const AccountManagementScreen(),
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

    // Drive number/date formatting off the active language so amounts use the
    // right grouping/decimal separators (e.g. de → 4.594,20). Updates live
    // because this runs on every rebuild when the locale changes.
    Intl.defaultLocale = locale?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;

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
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Startup sync + budget check are best-effort; never crash the UI if
      // Supabase isn't ready or the network is down.
      try {
        await _checkBudgetOnStartup();
        await ref.read(syncServiceProvider).syncAll();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    final l = AppLocalizations.of(context)!;
    final index = ref.watch(navIndexProvider);
    // Keep the PageView in sync when the tab is changed from elsewhere
    // (nav bar tap, swipe, or a screen jumping tabs e.g. dashboard graphs).
    ref.listen<int>(navIndexProvider, (_, next) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != next) {
        _pageController.animateToPage(
          next,
          duration: Motion.medium,
          curve: Motion.curve,
        );
      }
    });
    // Quick-add FAB only on Home + Records (entry-heavy screens).
    final showFab = index == 0 || index == 1;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) =>
            ref.read(navIndexProvider.notifier).state = i,
        children: const [
          DashboardScreen(),
          TransactionListScreen(),
          StatisticsScreen(),
          BudgetScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: showFab ? const SpeedDialFab() : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(navIndexProvider.notifier).state = i,
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
            icon: const Icon(Icons.savings_outlined),
            selectedIcon: const Icon(Icons.savings),
            label: l.budget,
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
