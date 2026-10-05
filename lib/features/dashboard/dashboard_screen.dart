import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:finio/app_localizations.dart';
import '../../core/sync/sync_service.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/providers/account_providers.dart';
import '../../shared/providers/budget_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/navigation_provider.dart';
import '../../shared/providers/privacy_provider.dart';
import '../../shared/providers/statistics_providers.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/utils/category_localizer.dart';
import '../../shared/widgets/balance_hero.dart';
import '../../shared/widgets/budget_ring.dart';
import '../../shared/widgets/mini_charts.dart';
import '../../shared/widgets/month_nav.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final transactionsAsync = ref.watch(monthlyTransactionsProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final currencyCode = ref.watch(currencyProvider);
    final categoryMap = {
      for (final c in ref.watch(allCategoriesProvider).valueOrNull ?? [])
        '${c.type}:${c.name}': c,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Finio')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(syncServiceProvider).syncAll(),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const MonthNav(),
            BalanceHero(
              totalBalance: ref.watch(totalBalanceProvider),
              monthlyIncome: ref.watch(monthlyIncomeProvider),
              monthlyExpense: ref.watch(monthlyExpenseProvider),
              todayIncome: ref.watch(todayIncomeProvider),
              todayExpense: ref.watch(todayExpenseProvider),
              symbol: symbol,
              currencyCode: currencyCode,
              hidden: ref.watch(hideAmountsProvider),
              onHiddenChanged: (v) =>
                  ref.read(hideAmountsProvider.notifier).setHidden(v),
            ),
            const _InsightsRow(),
            const _BudgetRings(),
            SectionHeader(l.recentTransactions),
            transactionsAsync.when(
              data: (txs) {
                if (txs.isEmpty) return const _EmptyState();
                final recent = txs.take(8).toList();
                return Column(
                  children: [
                    for (final tx in recent)
                      TransactionTile(
                        tx: tx,
                        category: categoryMap[categoryKeyOf(tx)],
                        symbol: symbol,
                        showDate: true,
                        onEdit: () =>
                            context.push('/transactions/add', extra: tx),
                        onDelete: () => ref
                            .read(appDatabaseProvider)
                            .transactionDao
                            .deleteTransaction(tx.id),
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(Insets.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(Insets.xl),
                child: Center(child: Text('${l.loadFailed}: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category donut as a full-width card that taps through to the Statistics
/// tab for detail. Full width keeps the legend readable (no truncated category
/// names).
class _InsightsRow extends ConsumerWidget {
  const _InsightsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final stats = ref.watch(categoryStatsProvider('expense'));
    if (stats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.sm),
      child: _InsightCard(
        onTap: () => ref.read(navIndexProvider.notifier).state = 2,
        child: Row(
          children: [
            MiniDonut(stats: stats, size: 88),
            const SizedBox(width: Insets.lg),
            Expanded(
              child: DonutLegend(
                stats: stats,
                labelOf: (k) => localizeCategory(l, k),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Insets.md),
          child: child,
        ),
      ),
    );
  }
}

/// Horizontal strip of animated budget rings (overall + per-category).
class _BudgetRings extends ConsumerWidget {
  const _BudgetRings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final statuses = ref.watch(budgetStatusesProvider);

    if (statuses.isEmpty) return const SizedBox.shrink();

    // ponytail: the period isn't shown on a 76px ring — the Budget tab spells
    // it out.
    final items = <Widget>[
      for (final s in statuses)
        _RingItem(
          label: s.budget.category == null
              ? l.overallBudget
              : localizeCategory(l, s.budget.category!),
          spent: s.spent,
          budget: s.limit,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          l.budget,
          action: TextButton(
            onPressed: () => ref.read(navIndexProvider.notifier).state = 3,
            child: Text(l.budgetSettings),
          ),
        ),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: Insets.lg),
            itemBuilder: (_, i) => items[i],
          ),
        ),
      ],
    );
  }
}

class _RingItem extends StatelessWidget {
  const _RingItem({
    required this.label,
    required this.spent,
    required this.budget,
  });

  final String label;
  final double spent;
  final double budget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          BudgetRing(spent: spent, budget: budget),
          const SizedBox(height: Insets.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(Insets.xxl),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 72, color: scheme.outlineVariant),
            const SizedBox(height: Insets.lg),
            Text(l.noRecords,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: scheme.outline)),
            const SizedBox(height: Insets.sm),
            Text(l.tapToStart,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.outlineVariant)),
          ],
        ),
      ),
    );
  }
}
