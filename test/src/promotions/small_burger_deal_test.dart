import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  const deal = SmallBurgerDeal();

  test('is automatic', () {
    expect(deal.requiresCoupon, isFalse);
  });

  group('isEligible', () {
    test('is true with a small burger', () {
      expect(
          deal.isEligible(Order.fromBag(Bag()..add('burger-small'))), isTrue);
    });

    test('is false with only medium and large burgers', () {
      final order = Order.fromBag(
        Bag()
          ..add('burger-medium')
          ..add('burger-large'),
      );

      expect(deal.isEligible(order), isFalse);
    });
  });

  group('apply', () {
    test('takes 2.00 off a small burger so it rings at 4.99', () {
      final order = deal.apply(Order.fromBag(Bag()..add('burger-small')));

      expect(order.discountCents, 200);
      expect(order.subtotalCents - order.discountCents, 499);
    });

    test('takes 2.00 off every small burger unit across lines', () {
      final order = deal.apply(
        Order.fromBag(
          Bag()
            ..add('burger-small', quantity: 2)
            ..add('burger-small'),
        ),
      );

      expect(order.discountCents, 600);
      expect(order.lineDiscountCents, {'burger-small': 600});
    });

    test('leaves medium and large burgers at full price', () {
      final order = deal.apply(
        Order.fromBag(
          Bag()
            ..add('burger-small')
            ..add('burger-large'),
        ),
      );

      expect(order.discountCents, 200);
    });

    test('changes nothing without a small burger', () {
      final order = deal.apply(Order.fromBag(Bag()..add('burger-medium')));

      expect(order.discountCents, 0);
      expect(order.lineDiscountCents, isEmpty);
    });
  });

  test('never discounts a small burger already at or below 4.99', () {
    final order = Order(
      lines: [
        OrderLine(
          const Product(
            id: 'burger-small',
            name: 'Classic Burger (Small)',
            category: 'burgers',
            priceCents: 450,
          ),
          quantity: 1,
        ),
      ],
    );

    expect(deal.isEligible(order), isFalse);
    expect(deal.apply(order).discountCents, 0);
  });
}
