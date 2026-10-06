import '../order.dart';
import 'promotion.dart';

/// A promotion that takes an amount off the order as a whole, not off
/// specific lines.
abstract class OrderDiscountPromotion extends Promotion {
  const OrderDiscountPromotion({
    required super.id,
    required super.name,
    required super.requiresCoupon,
  });

  /// Amount this promotion would take off [order]; zero or negative means
  /// it does not apply.
  int discountCentsFor(Order order);

  @override
  bool isEligible(Order order) => discountCentsFor(order) > 0;

  @override
  Order apply(Order order) {
    final cents = discountCentsFor(order);
    return cents > 0
        ? order.withPromotion(id: id, name: name, orderDiscountCents: cents)
        : order;
  }
}
