import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  const coupon = SweetToothCoupon();

  Order order(Map<String, int> quantities,
      {String? couponCode = 'SWEETTOOTH'}) {
    final bag = Bag();
    quantities.forEach((id, quantity) => bag.add(id, quantity: quantity));
    return Order.fromBag(bag, couponCode: couponCode);
  }

  test('requires a coupon', () {
    expect(coupon.requiresCoupon, isTrue);
  });

  group('isEligible', () {
    test('is true with the code and a dessert', () {
      expect(coupon.isEligible(order({'cookie': 1})), isTrue);
    });

    test('is false without a dessert', () {
      expect(coupon.isEligible(order({'burger-small': 1})), isFalse);
    });

    test('is false without the code', () {
      expect(
          coupon.isEligible(order({'cookie': 1}, couponCode: null)), isFalse);
    });
  });

  group('apply', () {
    test('makes one of two cookies free', () {
      final discounted = coupon.apply(order({'cookie': 2}));

      expect(discounted.discountCents, 179);
      expect(discounted.lineDiscountCents, {'cookie': 179});
    });

    test('makes the cookie free when a sundae is also in the bag', () {
      expect(
          coupon.apply(order({'sundae': 1, 'cookie': 1})).discountCents, 179);
    });

    test('comps exactly one dessert unit', () {
      expect(
          coupon.apply(order({'cookie': 2, 'sundae': 1})).discountCents, 179);
    });

    test('makes a lone sundae free', () {
      expect(coupon.apply(order({'sundae': 1})).discountCents, 329);
    });

    test('quietly does nothing without a dessert', () {
      expect(coupon.apply(order({'soda': 1})).discountCents, 0);
    });
  });
}
