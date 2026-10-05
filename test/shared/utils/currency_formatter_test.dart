import 'package:finio/shared/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatAmount always shows two decimals', () {
    expect(formatAmount(0, r'$'), r'$0.00');
    expect(formatAmount(1, r'$'), r'$1.00');
    expect(formatAmount(1200.5, r'$'), r'$1,200.50');
  });

  test('formatAmount puts the minus outside the symbol', () {
    expect(formatAmount(-80, r'$'), r'-$80.00');
    expect(formatAmount(-1234.5, 'RM'), '-RM1,234.50');
  });
}
