import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  const coupon = Four99Coupon();

  Order order(Map<String, int> quantities, {String? couponCode = 'FOUR99'}) {
    final bag = Bag();
    quantities.forEach((id, quantity) => bag.add(id, quantity: quantity));
    return Order.fromBag(bag, couponCode: couponCode);
  }

  test('requires a coupon', () {
    expect(coupon.requiresCoupon, isTrue);
  });

  group('isEligible', () {
    test('is true with the code and a burger', () {
      expect(coupon.isEligible(order({'burger-medium': 1})), isTrue);
    });

    test('is false without a burger', () {
      expect(coupon.isEligible(order({'fries-small': 1})), isFalse);
    });

    test('is false without the code', () {
      expect(coupon.isEligible(order({'burger-large': 1}, couponCode: null)),
          isFalse);
    });

    test('is false when the only burger is already at 4.99', () {
      final discounted = order({'burger-small': 1})
          .withDiscount(200, productId: 'burger-small');

      expect(coupon.isEligible(discounted), isFalse);
    });
  });

  group('apply', () {
    test('drops each burger size to 4.99', () {
      final discounted = coupon.apply(
        order({'burger-small': 1, 'burger-medium': 1, 'burger-large': 1}),
      );

      expect(discounted.lineDiscountCents, {
        'burger-small': 200,
        'burger-medium': 450,
        'burger-large': 700,
      });
      expect(discounted.discountCents, 1350);
    });

    test('applies to every unit of a burger', () {
      expect(coupon.apply(order({'burger-large': 2})).discountCents, 1400);
    });

    test('adds nothing to a small burger already at 4.99', () {
      final discounted = coupon.apply(
        order({'burger-small': 2, 'burger-medium': 1})
            .withDiscount(400, productId: 'burger-small'),
      );

      expect(discounted.lineDiscountCents, {
        'burger-small': 400,
        'burger-medium': 450,
      });
    });

    test('only tops up a burger to the 4.99 floor', () {
      final discounted = coupon.apply(
        order({'burger-medium': 1})
            .withDiscount(100, productId: 'burger-medium'),
      );

      expect(discounted.lineDiscountCents['burger-medium'], 450);
    });

    test('quietly does nothing without a burger', () {
      expect(coupon.apply(order({'soda': 3})).discountCents, 0);
    });
  });
}
