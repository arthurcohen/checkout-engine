import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  const coupon = Save5Coupon();

  Order thirtyDollars({String? couponCode = 'SAVE5'}) => Order.fromBag(
        Bag()
          ..add('burger-small', quantity: 3)
          ..add('milkshake')
          ..add('sparkling-water')
          ..add('sundae'),
        couponCode: couponCode,
      );

  test('requires a coupon', () {
    expect(coupon.requiresCoupon, isTrue);
  });

  group('isEligible', () {
    test('is true at exactly 30.00 with the code', () {
      expect(thirtyDollars().subtotalCents, 3000);
      expect(coupon.isEligible(thirtyDollars()), isTrue);
    });

    test('is false at 29.99', () {
      final order = Order.fromBag(
        Bag()
          ..add('burger-small', quantity: 3)
          ..add('fries-small')
          ..add('soda')
          ..add('sparkling-water')
          ..add('sundae'),
        couponCode: 'SAVE5',
      );

      expect(order.subtotalCents, 2999);
      expect(coupon.isEligible(order), isFalse);
    });

    test('measures the minimum on the original ring, before deals', () {
      final discounted = thirtyDollars().withDiscount(600);

      expect(coupon.isEligible(discounted), isTrue);
    });

    test('accepts the code in any case and with surrounding spaces', () {
      expect(coupon.isEligible(thirtyDollars(couponCode: ' save5 ')), isTrue);
    });

    test('is false without the code', () {
      expect(coupon.isEligible(thirtyDollars(couponCode: null)), isFalse);
      expect(coupon.isEligible(thirtyDollars(couponCode: 'SAVE50')), isFalse);
    });
  });

  group('apply', () {
    test('takes 5.00 off', () {
      expect(coupon.apply(thirtyDollars()).discountCents, 500);
    });

    test('adds to a discount already on the order', () {
      expect(
          coupon.apply(thirtyDollars().withDiscount(600)).discountCents, 1100);
    });

    test('quietly does nothing below the minimum', () {
      final order = Order.fromBag(Bag()..add('coffee'), couponCode: 'SAVE5');

      expect(coupon.apply(order).discountCents, 0);
    });
  });
}
