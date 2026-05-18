import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

String fullNameFromCode(String code) {
  const map = {
    'USD': '美元 USD', 'SGD': '新加坡元 SGD', 'MYR': '马来西亚令吉 MYR',
    'CNY': '人民币 CNY', 'JPY': '日元 JPY', 'EUR': '欧元 EUR',
    'GBP': '英镑 GBP', 'KRW': '韩元 KRW', 'THB': '泰铢 THB',
    'INR': '印度卢比 INR', 'TWD': '新台币 TWD', 'HKD': '港币 HKD',
  };
  return map[code] ?? code;
}

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
