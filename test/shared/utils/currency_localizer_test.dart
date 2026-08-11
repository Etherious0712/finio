import 'package:finio/app_localizations.dart';
import 'package:finio/shared/providers/currency_provider.dart';
import 'package:finio/shared/utils/currency_localizer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every supported currency has a localized name, region and symbol',
      () async {
    for (final locale in const [Locale('en'), Locale('zh')]) {
      final l = await AppLocalizations.delegate.load(locale);
      for (final code in kCurrencyCodes) {
        final name = localizeCurrencyName(l, code);
        expect(name, isNotEmpty, reason: '$code name missing in $locale');
        expect(name, isNot(code), reason: '$code name falls back in $locale');
        expect(localizeCurrencyRegion(l, code), isNotEmpty,
            reason: '$code region missing in $locale');
        // r'$' is also the fallback, so only unmapped non-dollar codes show up.
        expect(symbolFromCode(code), isNotEmpty);
      }
    }
  });
}
