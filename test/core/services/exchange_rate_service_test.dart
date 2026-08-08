import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:finio/core/services/exchange_rate_service.dart';

void main() {
  // Real responses, trimmed: Frankfurter 404s on any currency outside the ~30
  // ECB codes (TWD is one), while open.er-api.com covers 160+.
  const frankfurterNotFound = '{"message":"not found"}';
  const erApiTwd =
      '{"result":"success","base_code":"TWD","rates":{"TWD":1,"USD":0.031061}}';
  const frankfurterEur = '{"amount":1.0,"base":"USD","rates":{"EUR":0.8657}}';

  /// Records which hosts were hit so we can assert the fallback only fires when
  /// the primary actually fails.
  ({List<String> hosts, http.Client client}) mockClient(
      http.Response Function(Uri uri) respond) {
    final hosts = <String>[];
    return (
      hosts: hosts,
      client: MockClient((request) async {
        hosts.add(request.url.host);
        return respond(request.url);
      }),
    );
  }

  test('same currency short-circuits without any request', () async {
    final m = mockClient((_) => http.Response('should not be called', 500));
    final quote =
        await ExchangeRateService.getRate('USD', 'USD', client: m.client);
    expect(quote.rate, 1.0);
    expect(m.hosts, isEmpty);
  });

  test('falls back to er-api when Frankfurter 404s (the TWD case)', () async {
    final m = mockClient((uri) => uri.host.contains('frankfurter')
        ? http.Response(frankfurterNotFound, 404)
        : http.Response(erApiTwd, 200));

    final quote =
        await ExchangeRateService.getRate('TWD', 'USD', client: m.client);

    expect(quote.rate, closeTo(0.031061, 1e-9));
    expect(m.hosts, ['api.frankfurter.app', 'open.er-api.com']);
    // The dialog attributes the rate to this string, so it must name the
    // provider that actually answered.
    expect(quote.source, ExchangeRateService.erApiSource);
  });

  test('uses the Frankfurter rate and skips the fallback when it succeeds',
      () async {
    final m = mockClient((uri) => uri.host.contains('frankfurter')
        ? http.Response(frankfurterEur, 200)
        : http.Response(erApiTwd, 200));

    final quote =
        await ExchangeRateService.getRate('USD', 'EUR', client: m.client);

    expect(quote.rate, closeTo(0.8657, 1e-9));
    expect(m.hosts, ['api.frankfurter.app'], reason: 'er-api must not be hit');
    expect(quote.source, ExchangeRateService.frankfurterSource);
  });

  test('throws UnsupportedError when neither source knows the currency',
      () async {
    final m = mockClient((uri) => uri.host.contains('frankfurter')
        ? http.Response(frankfurterNotFound, 404)
        : http.Response('{"result":"error"}', 200));

    expect(
      () => ExchangeRateService.getRate('XYZ', 'USD', client: m.client),
      throwsUnsupportedError,
    );
  });

  test('rethrows when both sources are unreachable', () async {
    final m = mockClient((_) => http.Response('gateway down', 502));

    expect(
      () => ExchangeRateService.getRate('USD', 'TWD', client: m.client),
      throwsA(isA<Exception>()),
    );
  });
}
