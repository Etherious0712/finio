import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A custom numeric keypad for fast amount entry (no system keyboard). Operates
/// on a plain amount string; the parent owns the value.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  void _tap(String key) {
    if (key == '<') {
      if (value.isNotEmpty) onChanged(value.substring(0, value.length - 1));
      return;
    }
    if (key == '.') {
      if (value.contains('.') || value.isEmpty) return;
      onChanged('$value.');
      return;
    }
    // Block more than two decimal places.
    final dot = value.indexOf('.');
    if (dot >= 0 && value.length - dot > 2) return;
    // Avoid leading zeros like "00".
    if (value == '0') {
      onChanged(key);
      return;
    }
    onChanged('$value$key');
  }

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '<'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: [
        for (final k in keys)
          _Key(
            label: k,
            onTap: () => _tap(k),
          ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == '<';
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.md),
      onTap: onTap,
      child: Center(
        child: isBackspace
            ? const Icon(Icons.backspace_outlined, size: 22)
            : Text(label,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
      ),
    );
  }
}
