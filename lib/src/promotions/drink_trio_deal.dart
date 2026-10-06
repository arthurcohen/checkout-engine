import '../order.dart';
import 'line_discount_promotion.dart';
import 'promotion_support.dart';

const _excludedDrinkId = 'milkshake';
const _setSize = 3;

/// STORY 6: every complete set of three of the same drink has one free
/// unit. Milkshakes are excluded.
class DrinkTrioDeal extends LineDiscountPromotion {
  const DrinkTrioDeal()
      : super(
          id: 'drink-trio',
          name: 'Every Third Drink Free',
          requiresCoupon: false,
        );

  @override
  Map<String, int> computeLineDiscounts(Order order) => {
        for (final drink in productsInCategory(order, drinksCategory))
          if (drink.id != _excludedDrinkId)
            drink.id: order.quantityOf(drink.id) ~/ _setSize * drink.priceCents,
      };
}
