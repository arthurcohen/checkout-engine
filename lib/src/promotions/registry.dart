import 'drink_trio_deal.dart';
import 'drinks_bulk_deal.dart';
import 'four99_coupon.dart';
import 'free_small_fries_deal.dart';
import 'promotion.dart';
import 'save5_coupon.dart';
import 'small_burger_deal.dart';
import 'sweettooth_coupon.dart';
import 'welcome15_coupon.dart';

/// The engine reads this list when calculating an order. On equal totals
/// it prefers a combination with an automatic deal, then the promotion
/// listed first.
final List<Promotion> availablePromotions = [
  const SmallBurgerDeal(),
  const FreeSmallFriesDeal(),
  const DrinkTrioDeal(),
  const DrinksBulkDeal(),
  const Save5Coupon(),
  const Welcome15Coupon(),
  const SweetToothCoupon(),
  const Four99Coupon(),
];
