import 'package:finio/shared/utils/cents_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const f = CentsInputFormatter();

  /// Types [text] as a whole new field value after [old].
  String type(String text, {String old = ''}) => f
      .formatEditUpdate(
        TextEditingValue(text: old),
        TextEditingValue(text: text),
      )
      .text;

  group('CentsInputFormatter', () {
    test('digits shift in from the right with two decimals', () {
      expect(type('1'), '0.01');
      expect(type('0.012', old: '0.01'), '0.12');
      expect(type('0.123', old: '0.12'), '1.23');
      expect(type('1.234', old: '1.23'), '12.34');
    });

    test('groups thousands', () {
      expect(type('123456'), '1,234.56');
    });

    test('backspace drops the last digit', () {
      expect(type('12.3', old: '12.34'), '1.23');
      expect(type('0.0', old: '0.01'), '');
    });

    test('ignores anything that is not a digit', () {
      expect(type('1a-2,3'), '1.23');
    });

    test('rejects input past the digit cap', () {
      final full = type('9' * 12);
      expect(type('${full}9', old: full), full);
    });

    test('caret sits at the end', () {
      final v = f.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '5'),
      );
      expect(v.selection, const TextSelection.collapsed(offset: 4));
    });
  });

  test('parseCentsInput reads the field back as an amount', () {
    expect(parseCentsInput(''), isNull);
    expect(parseCentsInput('0.01'), 0.01);
    expect(parseCentsInput('1,234.56'), 1234.56);
  });

  test('centsTextFor seeds a field from an existing amount', () {
    expect(centsTextFor(0), '');
    expect(centsTextFor(12.5), '12.50');
    expect(centsTextFor(1234.567), '1,234.57');
    expect(centsTextFor(-80), '80.00');
  });
}
