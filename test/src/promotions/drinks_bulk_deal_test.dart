import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  const deal = DrinksBulkDeal();

  Order bag(Map<String, int> quantities) {
    final bag = Bag();
    quantities.forEach((id, quantity) => bag.add(id, quantity: quantity));
    return Order.fromBag(bag);
  }

  test('is automatic', () {
    expect(deal.requiresCoupon, isFalse);
  });

  group('isEligible', () {
    test('is true with three of the same drink', () {
      expect(deal.isEligible(bag({'coffee': 3})), isTrue);
    });

    test('is false with two of a drink', () {
      expect(deal.isEligible(bag({'coffee': 2})), isFalse);
    });

    test('is false with three plus two of different drinks', () {
      expect(deal.isEligible(bag({'soda': 2, 'coffee': 2})), isFalse);
    });

    test('is true with three milkshakes', () {
      expect(deal.isEligible(bag({'milkshake': 3})), isTrue);
    });
  });

  group('apply', () {
    test('takes 0.60 off three sodas', () {
      final order = deal.apply(bag({'soda': 3}));

      expect(order.discountCents, 60);
      expect(order.lineDiscountCents, {'soda': 60});
    });

    test('discounts only the qualifying drinks', () {
      final order = deal.apply(
        bag({'coffee': 4, 'burger-large': 1, 'soda': 2}),
      );

      expect(order.discountCents, 60);
      expect(order.lineDiscountCents, {'coffee': 60});
    });

    test('rounds each qualifying drink separately', () {
      final order = deal.apply(bag({'soda': 3, 'sparkling-water': 3}));

      expect(order.discountCents, 60 + 38);
    });

    test('includes milkshakes', () {
      expect(deal.apply(bag({'milkshake': 3})).discountCents, 135);
    });

    test('counts the same drink across separate lines', () {
      final order = deal.apply(
        Order.fromBag(
          Bag()
            ..add('soda')
            ..add('soda', quantity: 2),
        ),
      );

      expect(order.discountCents, 60);
    });

    test('changes nothing with fewer than three of any drink', () {
      expect(deal.apply(bag({'soda': 2, 'coffee': 2})).discountCents, 0);
    });
  });
}
