import 'package:flutter/material.dart';

import 'package:finio/app_localizations.dart';
import '../models/stats_models.dart';
import '../utils/currency_formatter.dart';

/// A credit card's balance as people say it: "Owed RM 500.00", or "Overpaid
/// RM 20.00" once it's paid past zero. Always positive — the sign lives in the
/// word.
String cardBalanceLabel(AppLocalizations l, AccountBalance b, String symbol) =>
    b.overpaid > 0
    ? l.overpaidAmount(formatAmount(b.overpaid, symbol))
    : l.owedAmount(formatAmount(b.owed, symbol));

/// "Available RM x / Limit RM y" under a credit card, or "No credit limit set"
/// for a card from before limits existed.
class CreditLine extends StatelessWidget {
  const CreditLine({super.key, required this.balance, required this.symbol});

  final AccountBalance balance;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final limit = balance.creditLimit;
    return Text(
      limit == null
          ? l.noCreditLimit
          : l.availableCredit(
              formatAmount(balance.available!, symbol),
              formatAmount(limit, symbol),
            ),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

/// Asks before saving a charge of [amount] on [card] when it's more than the
/// available credit. [credit] is credit the record being edited already used
/// (its old amount), which frees up again on save. Returns whether to go on —
/// over the limit is a warning, never a block.
Future<bool> confirmWithinLimit(
  BuildContext context, {
  required AccountBalance? card,
  required double amount,
  required String symbol,
  double credit = 0,
}) async {
  final available = card?.available;
  if (card == null || !card.isCreditCard || available == null) return true;
  final headroom = available + credit;
  if (amount <= headroom) return true;

  final l = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.overLimitTitle),
      content: Text(l.overLimitMsg(formatAmount(headroom, symbol))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l.save),
        ),
      ],
    ),
  );
  return ok ?? false;
}
