import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/app_localizations.dart';
import '../../shared/providers/locale_provider.dart';

const _kLocales = [
  (null, 'Follow System', '跟随系统 / Follow System'),
  ('en', 'English', 'English'),
  ('zh', '简体中文', '简体中文'),
  ('ja', '日本語', '日本語'),
  ('ko', '한국어', '한국어'),
  ('ms', 'Bahasa Melayu', 'Bahasa Melayu'),
  ('fr', 'Français', 'Français'),
  ('de', 'Deutsch', 'Deutsch'),
  ('es', 'Español', 'Español'),
];

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final current = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.language), centerTitle: true),
      body: RadioGroup<String?>(
        groupValue: current?.languageCode,
        onChanged: (code) => ref.read(localeProvider.notifier).setLocale(
              code == null ? null : Locale(code),
            ),
        child: ListView(
          children: [
            for (final (code, label, _) in _kLocales)
              RadioListTile<String?>(
                value: code,
                title: Text(label),
              ),
          ],
        ),
      ),
    );
  }
}
