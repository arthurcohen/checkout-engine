import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  const deal = DrinkTrioDeal();

  Order drinks(Map<String, int> quantities) {
    final bag = Bag();
    quantities.forEach((id, quantity) => bag.add(id, quantity: quantity));
    return Order.fromBag(bag);
  }

  test('is automatic', () {
    expect(deal.requiresCoupon, isFalse);
  });

  group('isEligible', () {
    test('is true with three of the same drink', () {
      expect(deal.isEligible(drinks({'soda': 3})), isTrue);
    });

    test('is false with two of a drink', () {
      expect(deal.isEligible(drinks({'soda': 2})), isFalse);
    });

    test('is false with three mixed drinks', () {
      expect(deal.isEligible(drinks({'soda': 2, 'coffee': 1})), isFalse);
    });

    test('is false with only milkshakes', () {
      expect(deal.isEligible(drinks({'milkshake': 6})), isFalse);
    });
  });

  group('apply', () {
    test('makes one of three sodas free', () {
      final order = deal.apply(drinks({'soda': 3}));

      expect(order.discountCents, 199);
      expect(order.lineDiscountCents, {'soda': 199});
    });

    test('makes two of six sodas free', () {
      expect(deal.apply(drinks({'soda': 6})).discountCents, 398);
    });

    test('gives no partial credit, five sodas pay for four', () {
      expect(deal.apply(drinks({'soda': 5})).discountCents, 199);
    });

    test('counts each drink type at its own price', () {
      final order = deal.apply(drinks({'soda': 3, 'coffee': 3}));

      expect(order.discountCents, 199 + 149);
      expect(order.lineDiscountCents, {'soda': 199, 'coffee': 149});
    });

    test('counts the same drink across separate lines', () {
      final order = deal.apply(
        Order.fromBag(
          Bag()
            ..add('soda', quantity: 2)
            ..add('soda'),
        ),
      );

      expect(order.discountCents, 199);
    });

    test('never makes a milkshake free', () {
      final order = deal.apply(drinks({'milkshake': 3, 'coffee': 3}));

      expect(order.discountCents, 149);
      expect(order.lineDiscountCents.containsKey('milkshake'), isFalse);
    });

    test('ignores three of a non-drink product', () {
      expect(deal.apply(drinks({'cookie': 3})).discountCents, 0);
    });
  });
}
