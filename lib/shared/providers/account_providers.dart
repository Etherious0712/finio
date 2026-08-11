import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/core/database/app_database.dart';
import '../models/stats_models.dart';
import 'database_provider.dart';
import 'transaction_providers.dart';

/// All savings jars (live stream).
final accountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(appDatabaseProvider).accountDao.watchAllAccounts();
});

/// The jar preselected for new transactions, if the user set one.
final defaultAccountProvider = Provider<Account?>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
  for (final a in accounts) {
    if (a.isDefault) return a;
  }
  return null;
});

/// Net balance per jar (all-time income − expense), highest first, with an
/// "unassigned" bucket appended when records exist outside any jar.
///
/// Deliberately **not** scoped by [recordScopeProvider]: "how much is in this
/// jar" is a running total, and the sum has to reconcile with the dashboard's
/// all-time [totalBalanceProvider].
final accountBalancesProvider = Provider<List<AccountBalance>>((ref) {
  final txs = ref.watch(allTransactionsProvider).valueOrNull ?? const [];
  final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];

  final totals = <String, double>{};
  // Seed every jar so a brand-new one shows up at 0 instead of vanishing.
  for (final a in accounts) {
    totals[a.name] = 0;
  }
  for (final t in txs) {
    final key = t.account ?? '';
    final signed = t.type == 'income' ? t.amount : -t.amount;
    totals[key] = (totals[key] ?? 0) + signed;
  }

  final byName = {for (final a in accounts) a.name: a};
  final result = <AccountBalance>[];
  for (final entry in totals.entries) {
    if (entry.key.isEmpty) continue; // unassigned handled below
    final a = byName[entry.key];
    result.add(AccountBalance(
      name: entry.key,
      icon: a?.icon ?? 'savings',
      color: a?.color ?? '#B0B0B0',
      balance: entry.value,
    ));
  }
  result.sort((a, b) => b.balance.compareTo(a.balance));

  // Unassigned last — it's a leftover bucket, not a jar the user made.
  if (totals.containsKey('')) {
    result.add(AccountBalance(
      name: '',
      icon: 'more_horiz',
      color: '#B0B0B0',
      balance: totals['']!,
    ));
  }
  return result;
});
