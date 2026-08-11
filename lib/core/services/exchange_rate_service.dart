import 'dart:convert';

import 'package:http/http.dart' as http;

/// A rate together with the provider it actually came from, so the UI can
/// attribute it honestly instead of assuming one source.
typedef RateQuote = ({double rate, String source});

class ExchangeRateService {
  // Frankfurter serves ECB reference rates: authoritative, but only ~30
  // currencies (no TWD). open.er-api.com covers 160+ and needs no API key, so
  // it backs up the codes the ECB list omits.
  static const _frankfurterBase = 'https://api.frankfurter.app';
  static const _erApiBase = 'https://open.er-api.com/v6/latest';

  static const frankfurterSource = 'Frankfurter (ECB)';
  static const erApiSource = 'open.er-api.com';

  static const _timeout = Duration(seconds: 10);

  /// Returns the exchange rate from [fromCode] to [toCode], plus which provider
  /// served it.
  ///
  /// Tries Frankfurter first, then falls back to open.er-api.com. Deliberately
  /// no hardcoded list of Frankfurter's supported codes — the list would rot as
  /// their coverage changes, and letting the call fail costs one request.
  ///
  /// Throws [UnsupportedError] when *neither* source knows the currency, and
  /// some other exception when both requests fail (network, server error).
  ///
  /// [client] exists only so tests can exercise the fallback branch.
  static Future<RateQuote> getRate(
    String fromCode,
    String toCode, {
    http.Client? client,
  }) async {
    if (fromCode == toCode) return (rate: 1.0, source: frankfurterSource);
    final http.Client c = client ?? http.Client();
    try {
      try {
        return (
          rate: await _frankfurter(c, fromCode, toCode),
          source: frankfurterSource,
        );
      } catch (_) {
        return (
          rate: await _erApi(c, fromCode, toCode),
          source: erApiSource,
        );
      }
    } finally {
      // Only close what we created; a caller-supplied client stays theirs.
      if (client == null) c.close();
    }
  }

  static Future<double> _frankfurter(
      http.Client client, String fromCode, String toCode) async {
    final uri =
        Uri.parse('$_frankfurterBase/latest?from=$fromCode&to=$toCode');
    final response = await client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Frankfurter HTTP ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final rates = json['rates'] as Map<String, dynamic>?;
    final rate = rates?[toCode];
    if (rate == null) {
      throw UnsupportedError('$toCode not supported by Frankfurter');
    }
    return (rate as num).toDouble();
  }

  static Future<double> _erApi(
      http.Client client, String fromCode, String toCode) async {
    final uri = Uri.parse('$_erApiBase/$fromCode');
    final response = await client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('er-api HTTP ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['result'] != 'success') {
      // An unknown base currency lands here.
      throw UnsupportedError('$fromCode not supported by er-api');
    }
    final rates = json['rates'] as Map<String, dynamic>?;
    final rate = rates?[toCode];
    if (rate == null) {
      throw UnsupportedError('$toCode not supported by er-api');
    }
    return (rate as num).toDouble();
  }
}
