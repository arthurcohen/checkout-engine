import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  const coupon = Welcome15Coupon();

  test('requires a coupon', () {
    expect(coupon.requiresCoupon, isTrue);
  });

  group('isEligible', () {
    test('is true with the code on any order', () {
      final order = Order.fromBag(Bag()..add('soda'), couponCode: 'WELCOME15');

      expect(coupon.isEligible(order), isTrue);
    });

    test('is false without the code', () {
      final order = Order.fromBag(Bag()..add('soda'), couponCode: 'SAVE5');

      expect(coupon.isEligible(order), isFalse);
    });
  });

  group('apply', () {
    test('takes 1.05 off a small burger, rounding 1.0485 half-up', () {
      final order = coupon.apply(
        Order.fromBag(Bag()..add('burger-small'), couponCode: 'WELCOME15'),
      );

      expect(order.discountCents, 105);
      expect(order.subtotalCents - order.discountCents, 594);
    });

    test('covers every line, sodas included', () {
      final order = coupon.apply(
        Order.fromBag(
          Bag()
            ..add('burger-large')
            ..add('soda', quantity: 2),
          couponCode: 'welcome15',
        ),
      );

      expect(order.discountCents, 240);
    });

    test('is computed on the original subtotal and adds to deals', () {
      final withDeal = Order.fromBag(
        Bag()..add('burger-small'),
        couponCode: 'WELCOME15',
      ).withDiscount(200, productId: 'burger-small');

      expect(coupon.apply(withDeal).discountCents, 305);
    });

    test('quietly does nothing without the code', () {
      final order = Order.fromBag(Bag()..add('salad'), couponCode: 'NOPE');

      expect(coupon.apply(order).discountCents, 0);
    });
  });

  test('is not eligible on an empty order', () {
    final order = Order.fromBag(Bag(), couponCode: 'WELCOME15');

    expect(coupon.isEligible(order), isFalse);
  });
}
