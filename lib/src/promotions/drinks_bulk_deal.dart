import '../money.dart';
import '../order.dart';
import 'line_discount_promotion.dart';
import 'promotion_support.dart';

const _minimumQuantity = 3;
const _discountBps = 1000;

/// STORY 7: 10% off every drink ordered three or more times, rounded
/// half-up per drink.
class DrinksBulkDeal extends LineDiscountPromotion {
  const DrinksBulkDeal()
      : super(
          id: 'drinks-bulk',
          name: '10% off 3+ of the Same Drink',
          requiresCoupon: false,
        );

  @override
  Map<String, int> computeLineDiscounts(Order order) => {
        for (final drink in productsInCategory(order, drinksCategory))
          drink.id: _bulkDiscount(order.quantityOf(drink.id), drink.priceCents),
      };

  int _bulkDiscount(int quantity, int unitPriceCents) =>
      quantity >= _minimumQuantity
          ? percentOfCents(quantity * unitPriceCents, _discountBps)
          : 0;
}
