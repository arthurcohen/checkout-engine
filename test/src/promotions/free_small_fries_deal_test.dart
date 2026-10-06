import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  const deal = FreeSmallFriesDeal();

  test('is automatic', () {
    expect(deal.requiresCoupon, isFalse);
  });

  group('isEligible', () {
    test('is true with any burger and a small fries', () {
      for (final burger in ['burger-small', 'burger-medium', 'burger-large']) {
        final order = Order.fromBag(
          Bag()
            ..add(burger)
            ..add('fries-small'),
        );

        expect(deal.isEligible(order), isTrue, reason: burger);
      }
    });

    test('is false without a burger', () {
      expect(
          deal.isEligible(Order.fromBag(Bag()..add('fries-small'))), isFalse);
    });

    test('is false when the only fries are large', () {
      final order = Order.fromBag(
        Bag()
          ..add('burger-medium')
          ..add('fries-large'),
      );

      expect(deal.isEligible(order), isFalse);
    });
  });

  group('apply', () {
    test('takes the 2.49 of one small fries off', () {
      final order = deal.apply(
        Order.fromBag(
          Bag()
            ..add('burger-large')
            ..add('fries-small'),
        ),
      );

      expect(order.discountCents, 249);
      expect(order.lineDiscountCents, {'fries-small': 249});
    });

    test('gives one free fries per order, not per burger', () {
      final order = deal.apply(
        Order.fromBag(
          Bag()
            ..add('burger-small', quantity: 2)
            ..add('fries-small', quantity: 2),
        ),
      );

      expect(order.discountCents, 249);
    });

    test('changes nothing without a burger', () {
      final order = deal.apply(Order.fromBag(Bag()..add('fries-small')));

      expect(order.discountCents, 0);
    });
  });
}
