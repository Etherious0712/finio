import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/currency_provider.dart';
import '../../shared/utils/currency_localizer.dart';
import 'package:finio/app_localizations.dart';

class CurrencyScreen extends ConsumerWidget {
  const CurrencyScreen({super.key});

  Future<void> _handleSelection(
    BuildContext context,
    WidgetRef ref,
    String newCode,
  ) async {
    final l = AppLocalizations.of(context)!;
    final currentCode = ref.read(currencyProvider);
    if (newCode == currentCode) return;

    String label(String code) =>
        '$code · ${symbolFromCode(code)} ${localizeCurrencyName(l, code)}';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.confirmCurrencyConvert),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: l.fromLabel, value: label(currentCode)),
            _InfoRow(label: l.toLabel, value: label(newCode)),
            const SizedBox(height: 12),
            Text(l.currencyConvertWarning, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.confirmConvert),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(currencyProvider.notifier).setCode(newCode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final currentCode = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.currency), centerTitle: true),
      body: RadioGroup<String>(
        groupValue: currentCode,
        onChanged: (v) => _handleSelection(context, ref, v!),
        child: ListView(
          children: [
            for (final code in kCurrencyCodes)
              RadioListTile<String>(
                value: code,
                title: Text(
                  '${symbolFromCode(code)}  ${localizeCurrencyName(l, code)}',
                ),
                subtitle: Text('$code · ${localizeCurrencyRegion(l, code)}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // No fixed width: 24px fits "从"/"至" but shreds "From:"/"Desde:".
          Text(
            '$label: ',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
