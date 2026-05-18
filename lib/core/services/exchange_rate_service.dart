import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const _base = 'https://api.frankfurter.app';

  /// Returns the exchange rate from [fromCode] to [toCode].
  /// Throws on network error or unsupported currency.
  static Future<double> getRate(String fromCode, String toCode) async {
    if (fromCode == toCode) return 1.0;
    final uri = Uri.parse('$_base/latest?from=$fromCode&to=$toCode');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final rates = json['rates'] as Map<String, dynamic>;
    if (!rates.containsKey(toCode)) {
      throw UnsupportedError('$toCode not supported by Frankfurter');
    }
    return (rates[toCode] as num).toDouble();
  }
}
