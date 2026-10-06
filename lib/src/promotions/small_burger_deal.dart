import '../order.dart';
import 'line_discount_promotion.dart';
import 'promotion_support.dart';

const _smallBurgerId = 'burger-small';
const _dealPriceCents = 499;

/// STORY 4: the small burger rings at $4.99, automatically.
class SmallBurgerDeal extends LineDiscountPromotion {
  const SmallBurgerDeal()
      : super(
          id: 'small-burger-499',
          name: r'Small Burger for $4.99',
          requiresCoupon: false,
        );

  @override
  Map<String, int> computeLineDiscounts(Order order) => {
        for (final burger in distinctProducts(order))
          if (burger.id == _smallBurgerId)
            burger.id: priceFloorDiscount(
              burger.priceCents,
              quantity: order.quantityOf(burger.id),
              floorCents: _dealPriceCents,
            ),
      };
}
