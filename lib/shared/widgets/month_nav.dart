import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_providers.dart';

class MonthNav extends ConsumerWidget {
  const MonthNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final m = ref.read(selectedMonthProvider);
            ref.read(selectedMonthProvider.notifier).state =
                DateTime(m.year, m.month - 1);
          },
        ),
        Text(
          DateFormat('yyyy年M月').format(month),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final m = ref.read(selectedMonthProvider);
            ref.read(selectedMonthProvider.notifier).state =
                DateTime(m.year, m.month + 1);
          },
        ),
      ],
    );
  }
}
