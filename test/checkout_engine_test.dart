import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Bag', () {
    test('collects items with quantities', () {
      final bag = Bag()
        ..add('burger-small')
        ..add('soda', quantity: 3);

      expect(bag.items, hasLength(2));
      expect(bag.items[0].productId, 'burger-small');
      expect(bag.items[0].quantity, 1);
      expect(bag.items[1].quantity, 3);
    });
  });

  group('Order', () {
    test('builds lines from a bag', () {
      final bag = Bag()
        ..add('burger-small')
        ..add('soda', quantity: 2);
      final order = Order.fromBag(bag);

      expect(order.lines, hasLength(2));
      expect(order.lines[0].lineTotalCents, 699);
      expect(order.lines[1].lineTotalCents, 398);
    });

    test('subtotal is the sum of line totals', () {
      final order = Order.fromBag(
        Bag()
          ..add('coffee', quantity: 2)
          ..add('salad'),
      );

      // 149 * 2 + 549
      expect(order.subtotalCents, 847);
    });

    test('tax is computed at 8.75%', () {
      final order = Order.fromBag(Bag()..add('salad'));

      expect(order.taxCents, 48);
    });

    test('total is subtotal plus tax when there is no discount', () {
      final order = Order.fromBag(
        Bag()..add('burger-small'), // 699
      );

      expect(order.totalCents, 699 + 61);
    });

    test('line discounts are tracked per product', () {
      final order = Order.fromBag(
        Bag()..add('burger-small', quantity: 2),
      );

      final discounted = order.copyWith(
        discountCents: 400,
        lineDiscountCents: {'burger-small': 400},
      );

      expect(discounted.discountCents, 400);
      expect(discounted.lineDiscountCents['burger-small'], 400);
    });

    test('discount is stored without touching the line prices', () {
      final order = Order.fromBag(
        Bag()
          ..add('coffee', quantity: 2)
          ..add('soda'), // 149 * 2 + 199 = 497
      );

      final discounted = order.copyWith(discountCents: 47);

      expect(discounted.discountCents, 47);
      expect(discounted.subtotalCents, order.subtotalCents);
    });
  });

  group('CheckoutEngine', () {
    test('calculate keeps line prices and consistent totals', () {
      final engine = const CheckoutEngine();
      final order = Order.fromBag(
        Bag()
          ..add('burger-small')
          ..add('coffee'), // 699 + 149 = 848
      );

      final result = engine.calculate(order);

      expect(result.subtotalCents, 848);
      expect(
        result.totalCents,
        result.subtotalCents - result.discountCents + result.taxCents,
      );
    });
  });
}
