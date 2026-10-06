import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

class _StubOrderDeal extends OrderDiscountPromotion {
  final int cents;

  const _StubOrderDeal(this.cents)
      : super(id: 'stub', name: 'Stub', requiresCoupon: true);

  @override
  int discountCentsFor(Order order) => cents;
}

void main() {
  final order = Order.fromBag(Bag()..add('salad'));

  test('is eligible when it discounts something', () {
    expect(const _StubOrderDeal(100).isEligible(order), isTrue);
  });

  test('is not eligible when the discount is zero or negative', () {
    expect(const _StubOrderDeal(0).isEligible(order), isFalse);
    expect(const _StubOrderDeal(-50).isEligible(order), isFalse);
  });

  test('adds its discount to the order', () {
    expect(const _StubOrderDeal(100).apply(order).discountCents, 100);
  });

  test('leaves the order untouched when not eligible', () {
    expect(const _StubOrderDeal(-50).apply(order).discountCents, 0);
  });
}
