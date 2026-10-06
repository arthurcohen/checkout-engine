import '../order.dart';
import 'line_discount_promotion.dart';
import 'promotion_support.dart';

const _smallFriesId = 'fries-small';

/// STORY 5: one small fries free per order that has any burger.
class FreeSmallFriesDeal extends LineDiscountPromotion {
  const FreeSmallFriesDeal()
      : super(
          id: 'free-small-fries',
          name: 'Free Small Fries with any Burger',
          requiresCoupon: false,
        );

  @override
  Map<String, int> computeLineDiscounts(Order order) {
    final hasBurger = productsInCategory(order, burgersCategory).isNotEmpty;
    final smallFries =
        distinctProducts(order).where((product) => product.id == _smallFriesId);
    if (!hasBurger || smallFries.isEmpty) return const {};
    return {_smallFriesId: smallFries.first.priceCents};
  }
}
