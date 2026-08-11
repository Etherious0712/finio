import 'package:finio/app_localizations.dart';

/// Translates a currency code (e.g. 'USD') to its localized display name.
/// Unknown codes are returned as-is.
String localizeCurrencyName(AppLocalizations l, String code) {
  return switch (code) {
    'USD' => l.curUSD,
    'SGD' => l.curSGD,
    'MYR' => l.curMYR,
    'CNY' => l.curCNY,
    'JPY' => l.curJPY,
    'EUR' => l.curEUR,
    'GBP' => l.curGBP,
    'KRW' => l.curKRW,
    'THB' => l.curTHB,
    'INR' => l.curINR,
    'TWD' => l.curTWD,
    'HKD' => l.curHKD,
    _ => code,
  };
}

/// Translates a currency code to the localized country/region it belongs to.
/// Unknown codes yield an empty string.
String localizeCurrencyRegion(AppLocalizations l, String code) {
  return switch (code) {
    'USD' => l.curRegionUSD,
    'SGD' => l.curRegionSGD,
    'MYR' => l.curRegionMYR,
    'CNY' => l.curRegionCNY,
    'JPY' => l.curRegionJPY,
    'EUR' => l.curRegionEUR,
    'GBP' => l.curRegionGBP,
    'KRW' => l.curRegionKRW,
    'THB' => l.curRegionTHB,
    'INR' => l.curRegionINR,
    'TWD' => l.curRegionTWD,
    'HKD' => l.curRegionHKD,
    _ => '',
  };
}
