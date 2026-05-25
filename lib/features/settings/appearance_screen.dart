import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/app_localizations.dart';
import '../../shared/providers/theme_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final current = ref.watch(themeProvider);

    void pick(AppThemeMode mode) =>
        ref.read(themeProvider.notifier).setTheme(mode);

    return Scaffold(
      appBar: AppBar(title: Text(l.appearance), centerTitle: true),
      body: RadioGroup<AppThemeMode>(
        groupValue: current,
        onChanged: (v) => pick(v!),
        child: ListView(
          children: [
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.system,
              title: Text(l.followSystem),
            ),
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.light,
              title: Text(l.lightMode),
            ),
            RadioListTile<AppThemeMode>(
              value: AppThemeMode.dark,
              title: Text(l.darkMode),
            ),
          ],
        ),
      ),
    );
  }
}
