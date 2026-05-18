import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/theme_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);

    void pick(AppThemeMode mode) =>
        ref.read(themeProvider.notifier).setTheme(mode);

    return Scaffold(
      appBar: AppBar(title: const Text('外观设置'), centerTitle: true),
      body: RadioGroup<AppThemeMode>(
        groupValue: current,
        onChanged: (v) => pick(v!),
        child: ListView(
          children: const [
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.system,
              title: Text('跟随系统'),
              subtitle: Text('Follow System'),
            ),
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.light,
              title: Text('浅色'),
              subtitle: Text('Light'),
            ),
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.dark,
              title: Text('深色'),
              subtitle: Text('Dark'),
            ),
          ],
        ),
      ),
    );
  }
}
