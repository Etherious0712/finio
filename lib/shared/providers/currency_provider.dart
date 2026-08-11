import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The supported currencies, in display order. Names and countries are
/// localized via `localizeCurrencyName` / `localizeCurrencyRegion`.
const kCurrencyCodes = [
  'USD', 'SGD', 'MYR', 'CNY', 'JPY', 'EUR',
  'GBP', 'KRW', 'THB', 'INR', 'TWD', 'HKD',
];

String symbolFromCode(String code) {
  const map = {
    'USD': r'$',
    'SGD': r'$',
    'MYR': 'RM',
    'CNY': '¥',
    'JPY': '¥',
    'EUR': '€',
    'GBP': '£',
    'KRW': '₩',
    'THB': '฿',
    'INR': '₹',
    'TWD': r'NT$',
    'HKD': r'HK$',
  };
  return map[code] ?? r'$';
}

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super('USD') {
    _load();
  }

  static const _key = 'currency_code';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) state = saved;
  }

  Future<void> setCode(String code) async {
    state = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }
}

final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, String>((_) => CurrencyNotifier());

final currencySymbolProvider = Provider<String>(
  (ref) => symbolFromCode(ref.watch(currencyProvider)),
);
