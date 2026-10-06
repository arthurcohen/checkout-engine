import '../money.dart';
import '../order.dart';
import 'order_discount_promotion.dart';
import 'promotion_support.dart';

const _code = 'WELCOME15';
const _discountBps = 1500;

/// STORY 2: 15% off the original subtotal with code WELCOME15, rounded
/// half-up.
class Welcome15Coupon extends OrderDiscountPromotion {
  const Welcome15Coupon()
      : super(id: 'welcome15', name: '15% off', requiresCoupon: true);

  @override
  int discountCentsFor(Order order) => hasCouponCode(order, _code)
      ? percentOfCents(order.subtotalCents, _discountBps)
      : 0;
}
