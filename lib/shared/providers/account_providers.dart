import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/core/database/app_database.dart';
import '../models/stats_models.dart';
import 'database_provider.dart';
import 'transaction_providers.dart';

/// All accounts (live stream).
final accountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(appDatabaseProvider).accountDao.watchAllAccounts();
});

/// The account preselected for new transactions, if the user set one.
final defaultAccountProvider = Provider<Account?>((ref) {
  final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
  for (final a in accounts) {
    if (a.isDefault) return a;
  }
  return null;
});

/// Balance per account — opening balance, plus all-time income − expense, plus
/// transfers in − transfers out. Highest first, with an "unassigned" bucket
/// appended when records exist outside any account.
///
/// Deliberately **not** scoped by [recordScopeProvider]: "how much is in this
/// account" is a running total, and the sum has to reconcile with the
/// dashboard's all-time [totalBalanceProvider].
final accountBalancesProvider = Provider<List<AccountBalance>>((ref) {
  final txs = ref.watch(allTransactionsProvider).valueOrNull ?? const [];
  final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];

  final totals = <String, double>{};
  // Seed at the opening balance, not 0: an account can hold money that predates
  // tracking, and a credit card can hold debt.
  for (final a in accounts) {
    totals[a.name] = a.openingBalance;
  }
  // A name with no account row (its account was deleted) falls into unassigned
  // rather than rendering a phantom row.
  String bucket(String? name) => totals.containsKey(name) ? name! : '';
  for (final t in txs) {
    final from = bucket(t.account);
    switch (t.type) {
      case 'income':
        totals[from] = (totals[from] ?? 0) + t.amount;
      case 'transfer':
        final to = bucket(t.toAccount);
        totals[from] = (totals[from] ?? 0) - t.amount;
        totals[to] = (totals[to] ?? 0) + t.amount;
      default: // 'expense'
        totals[from] = (totals[from] ?? 0) - t.amount;
    }
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
      type: a?.type ?? '',
      balance: entry.value,
    ));
  }
  result.sort((a, b) => b.balance.compareTo(a.balance));

  // Unassigned last — it's a leftover bucket, not an account the user made.
  if (totals.containsKey('')) {
    result.add(AccountBalance(
      name: '',
      icon: 'more_horiz',
      color: '#B0B0B0',
      type: '',
      balance: totals['']!,
    ));
  }
  return result;
});

/// All-time net worth: every account's balance, opening balances included and
/// credit-card debt subtracting. Derived from [accountBalancesProvider] so the
/// dashboard hero, the statistics total and the account list can never disagree.
final totalBalanceProvider = Provider<double>((ref) =>
    ref.watch(accountBalancesProvider).fold(0.0, (s, b) => s + b.balance));
