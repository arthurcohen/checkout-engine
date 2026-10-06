import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

class _StubLineDeal extends LineDiscountPromotion {
  final Map<String, int> discounts;
  int computeCalls = 0;

  _StubLineDeal(this.discounts)
      : super(id: 'stub', name: 'Stub', requiresCoupon: false);

  @override
  Map<String, int> computeLineDiscounts(Order order) {
    computeCalls++;
    return discounts;
  }
}

void main() {
  final order = Order.fromBag(
    Bag()
      ..add('soda')
      ..add('coffee'),
  );

  test('is not eligible when every line discount is zero', () {
    expect(_StubLineDeal({'soda': 0}).isEligible(order), isFalse);
  });

  test('drops zero and negative entries from lineDiscountsFor', () {
    final deal = _StubLineDeal({'soda': 150, 'coffee': -100, 'cookie': 0});

    expect(deal.lineDiscountsFor(order), {'soda': 150});
  });

  test('never adds money back to a line', () {
    final applied = _StubLineDeal({'soda': 150, 'coffee': -100}).apply(order);

    expect(applied.discountCents, 150);
    expect(applied.lineDiscountCents, {'soda': 150});
  });

  test('leaves the order untouched when nothing is discounted', () {
    final applied = _StubLineDeal({'soda': 0}).apply(order);

    expect(applied.discountCents, 0);
    expect(applied.lineDiscountCents, isEmpty);
  });

  test('computes the line discounts once per apply', () {
    final deal = _StubLineDeal({'soda': 150});

    deal.apply(order);

    expect(deal.computeCalls, 1);
  });
}
