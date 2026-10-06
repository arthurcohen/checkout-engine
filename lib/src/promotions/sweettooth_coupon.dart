import '../order.dart';
import 'line_discount_promotion.dart';
import 'promotion_support.dart';

const _code = 'SWEETTOOTH';

/// STORY 3: one unit of the cheapest dessert in the bag is free with code
/// SWEETTOOTH.
class SweetToothCoupon extends LineDiscountPromotion {
  const SweetToothCoupon()
      : super(id: 'sweettooth', name: 'Free Dessert', requiresCoupon: true);

  @override
  Map<String, int> computeLineDiscounts(Order order) {
    final desserts = productsInCategory(order, dessertsCategory);
    if (!hasCouponCode(order, _code) || desserts.isEmpty) return const {};
    final cheapest = desserts.reduce(
      (cheapest, dessert) =>
          dessert.priceCents < cheapest.priceCents ? dessert : cheapest,
    );
    return {cheapest.id: cheapest.priceCents};
  }
}
