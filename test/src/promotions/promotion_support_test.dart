import 'package:checkout_engine/checkout_engine.dart';
import 'package:checkout_engine/src/promotions/promotion_support.dart';
import 'package:test/test.dart';

void main() {
  OrderLine line(String id, int quantity) =>
      OrderLine(catalog[id]!, quantity: quantity);

  group('distinctProducts', () {
    test('lists each product once, in order of appearance', () {
      final order = Order(
        lines: [line('soda', 1), line('coffee', 1), line('soda', 2)],
      );

      expect(distinctProducts(order).map((product) => product.id), [
        'soda',
        'coffee',
      ]);
    });

    test('leaves out products without any unit', () {
      final order = Order(lines: [line('fries-small', 0), line('soda', 1)]);

      expect(distinctProducts(order).map((product) => product.id), ['soda']);
    });
  });

  group('priceFloorDiscount', () {
    test('takes every unit down to the floor', () {
      expect(priceFloorDiscount(699, quantity: 2, floorCents: 499), 400);
    });

    test('is zero when the price is already at or below the floor', () {
      expect(priceFloorDiscount(499, quantity: 1, floorCents: 499), 0);
      expect(priceFloorDiscount(450, quantity: 3, floorCents: 499), 0);
    });
  });

  group('promotions on lines without units', () {
    test('free fries ignores an empty small fries line', () {
      final order = Order(
        lines: [line('burger-medium', 1), line('fries-small', 0)],
      );

      expect(const FreeSmallFriesDeal().isEligible(order), isFalse);
    });

    test('free fries ignores an empty burger line', () {
      final order = Order(
        lines: [line('burger-medium', 0), line('fries-small', 1)],
      );

      expect(const FreeSmallFriesDeal().isEligible(order), isFalse);
    });

    test('SWEETTOOTH comps the sundae, not an empty cookie line', () {
      final order = Order(
        lines: [line('cookie', 0), line('sundae', 1)],
        couponCode: 'SWEETTOOTH',
      );

      expect(const SweetToothCoupon().lineDiscountsFor(order), {
        'sundae': 329,
      });
    });
  });
}
