import 'package:checkout_engine/src/money.dart';
import 'package:test/test.dart';

void main() {
  group('roundHalfUp', () {
    test('rounds an exact half up', () {
      expect(roundHalfUp(5, 10), 1);
    });

    test('rounds above half up', () {
      expect(roundHalfUp(10485, 100), 105);
    });

    test('rounds below half down', () {
      expect(roundHalfUp(104, 100), 1);
    });

    test('keeps exact values', () {
      expect(roundHalfUp(500, 100), 5);
    });

    test('returns zero for zero', () {
      expect(roundHalfUp(0, 100), 0);
    });
  });

  group('percentOfCents', () {
    test('rounds fifteen percent of a small burger to 105 cents', () {
      expect(percentOfCents(699, 1500), 105);
    });

    test('rounds ten percent of three sodas to 60 cents', () {
      expect(percentOfCents(597, 1000), 60);
    });

    test('rounds 8.75 percent of 1096 cents up to 96 cents', () {
      expect(percentOfCents(1096, 875), 96);
    });
  });
}
