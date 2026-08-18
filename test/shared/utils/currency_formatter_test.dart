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

  group('formatAmountInput', () {
    test('empty settles at 0.00', () => expect(formatAmountInput(''), '0.00'));

    test('groups the integer part', () {
      expect(formatAmountInput('1200'), '1,200');
      expect(formatAmountInput('1234567'), '1,234,567');
    });

    test('leaves in-progress decimals alone', () {
      expect(formatAmountInput('12.'), '12.');
      expect(formatAmountInput('12.5'), '12.5');
      expect(formatAmountInput('1234.56'), '1,234.56');
    });

    test('falls back to raw text when the integer part overflows int', () {
      final huge = '9' * 25;
      expect(formatAmountInput(huge), huge);
    });
  });
}
