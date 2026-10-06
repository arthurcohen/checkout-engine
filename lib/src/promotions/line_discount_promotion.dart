import '../order.dart';
import 'promotion.dart';

/// A promotion whose discount is attributed to specific product lines and
/// recorded in [Order.lineDiscountCents].
abstract class LineDiscountPromotion extends Promotion {
  const LineDiscountPromotion({
    required super.id,
    required super.name,
    required super.requiresCoupon,
  });

  /// Discount per product id this promotion would give on [order].
  /// Zero or negative entries are allowed and ignored.
  Map<String, int> computeLineDiscounts(Order order);

  /// The positive discounts from [computeLineDiscounts]; empty means the
  /// promotion does not apply.
  Map<String, int> lineDiscountsFor(Order order) => Map.fromEntries(
        computeLineDiscounts(order).entries.where((entry) => entry.value > 0),
      );

  @override
  bool isEligible(Order order) => lineDiscountsFor(order).isNotEmpty;

  @override
  Order apply(Order order) {
    final discounts = lineDiscountsFor(order);
    return discounts.isEmpty
        ? order
        : order.withPromotion(
            id: id,
            name: name,
            lineDiscountCents: discounts,
          );
  }
}
