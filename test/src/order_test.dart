import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Order.taxCents', () {
    test('is computed on the amount after discounts', () {
      final order = Order.fromBag(
        Bag()
          ..add('burger-small')
          ..add('soda', quantity: 3),
      ).copyWith(discountCents: 200);

      expect(order.taxCents, 96);
    });

    test('rounds half up instead of truncating', () {
      final order = Order.fromBag(Bag()..add('salad', quantity: 2));

      expect(order.taxCents, 96);
    });

    test('is zero when the discount covers the whole subtotal', () {
      final order =
          Order.fromBag(Bag()..add('coffee')).copyWith(discountCents: 500);

      expect(order.taxCents, 0);
    });
  });

  group('Order.totalCents', () {
    test('matches the Finance reference example of 11.92', () {
      final order = Order.fromBag(
        Bag()
          ..add('burger-small')
          ..add('soda', quantity: 3),
      ).copyWith(discountCents: 200);

      expect(order.totalCents, 1192);
    });

    test('never goes below zero', () {
      final order =
          Order.fromBag(Bag()..add('coffee')).copyWith(discountCents: 500);

      expect(order.totalCents, 0);
    });
  });

  group('Order.quantityOf', () {
    test('sums every line of the same product', () {
      final order = Order.fromBag(
        Bag()
          ..add('soda', quantity: 2)
          ..add('coffee')
          ..add('soda'),
      );

      expect(order.quantityOf('soda'), 3);
    });

    test('is zero for a product not in the order', () {
      final order = Order.fromBag(Bag()..add('coffee'));

      expect(order.quantityOf('soda'), 0);
    });
  });

  group('Order.withDiscount', () {
    test('adds to the existing order discount', () {
      final order = Order.fromBag(Bag()..add('burger-large'))
          .copyWith(discountCents: 100);

      expect(order.withDiscount(250).discountCents, 350);
    });

    test('merges line discounts instead of replacing them', () {
      final order = Order.fromBag(
        Bag()
          ..add('burger-small')
          ..add('fries-small'),
      ).withDiscount(200, productId: 'burger-small');

      final discounted = order.withDiscount(249, productId: 'fries-small');

      expect(discounted.lineDiscountCents, {
        'burger-small': 200,
        'fries-small': 249,
      });
    });

    test('accumulates line discounts on the same product', () {
      final order = Order.fromBag(Bag()..add('burger-medium'))
          .withDiscount(100, productId: 'burger-medium')
          .withDiscount(150, productId: 'burger-medium');

      expect(order.lineDiscountCents['burger-medium'], 250);
    });

    test('keeps the coupon code and does not mutate the original', () {
      final order = Order.fromBag(Bag()..add('soda'), couponCode: 'SAVE5');

      final discounted = order.withDiscount(50, productId: 'soda');

      expect(discounted.couponCode, 'SAVE5');
      expect(order.discountCents, 0);
      expect(order.lineDiscountCents, isEmpty);
    });
  });

  group('Order.appliedPromotions', () {
    const smallBurger = AppliedPromotion(
      id: 'small-burger-499',
      name: r'Small Burger for $4.99',
      discountCents: 200,
    );

    test('is empty by default', () {
      expect(Order.fromBag(Bag()..add('soda')).appliedPromotions, isEmpty);
    });

    test('is set through copyWith and kept by withDiscount', () {
      final order = Order.fromBag(Bag()..add('burger-small'))
          .copyWith(appliedPromotions: [smallBurger]).withDiscount(50);

      expect(order.appliedPromotions, [smallBurger]);
    });

    test('cannot be modified from outside', () {
      final order = Order.fromBag(Bag()..add('burger-small'))
          .copyWith(appliedPromotions: [smallBurger]);

      expect(() => order.appliedPromotions.clear(), throwsUnsupportedError);
    });
  });

  group('Order.withPromotion', () {
    test('adds an order-wide discount and records the promotion', () {
      final order = Order.fromBag(Bag()..add('salad'))
          .withPromotion(id: 'p', name: 'P', orderDiscountCents: 80);

      expect(order.discountCents, 80);
      expect(order.lineDiscountCents, isEmpty);
      expect(order.appliedPromotions, [
        const AppliedPromotion(id: 'p', name: 'P', discountCents: 80),
      ]);
    });

    test('adds line discounts and records their sum', () {
      final order = Order.fromBag(
        Bag()
          ..add('burger-small')
          ..add('fries-small'),
      ).withDiscount(100, productId: 'burger-small').withPromotion(
        id: 'p',
        name: 'P',
        lineDiscountCents: {'burger-small': 100, 'fries-small': 249},
      );

      expect(order.discountCents, 449);
      expect(order.lineDiscountCents, {
        'burger-small': 200,
        'fries-small': 249,
      });
      expect(order.appliedPromotions.single.discountCents, 349);
    });

    test('appends after promotions already recorded', () {
      final order = Order.fromBag(Bag()..add('salad'))
          .withPromotion(id: 'a', name: 'A', orderDiscountCents: 10)
          .withPromotion(id: 'b', name: 'B', orderDiscountCents: 20);

      expect(order.appliedPromotions.map((applied) => applied.id), [
        'a',
        'b',
      ]);
    });
  });

  group('promotions applied outside the engine', () {
    test('a coupon records itself', () {
      final order = Order.fromBag(
        Bag()..add('burger-small'),
        couponCode: 'WELCOME15',
      );

      final applied = const Welcome15Coupon().apply(order);

      expect(applied.appliedPromotions, [
        const AppliedPromotion(
          id: 'welcome15',
          name: '15% off',
          discountCents: 105,
        ),
      ]);
    });

    test('a line deal records itself', () {
      final applied = const SmallBurgerDeal().apply(
        Order.fromBag(Bag()..add('burger-small', quantity: 2)),
      );

      expect(applied.appliedPromotions.single.discountCents, 400);
    });

    test('nothing is recorded when the promotion does not apply', () {
      final applied = const Save5Coupon().apply(
        Order.fromBag(Bag()..add('coffee'), couponCode: 'SAVE5'),
      );

      expect(applied.appliedPromotions, isEmpty);
    });
  });

  group('AppliedPromotion', () {
    test('compares by value', () {
      expect(
        const AppliedPromotion(id: 'a', name: 'A', discountCents: 1),
        const AppliedPromotion(id: 'a', name: 'A', discountCents: 1),
      );
    });
  });
}
