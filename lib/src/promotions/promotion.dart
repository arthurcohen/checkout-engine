import '../order.dart';

/// The contract every promotion must follow. Concrete promotions are
/// discovered by the engine through `promotions/registry.dart`.
abstract class Promotion {
  /// Stable identifier for this promotion. Not necessarily its coupon code —
  /// how a coupon recognizes its marketing code (see stories.md) is up to
  /// the implementation, via `order.couponCode`.
  final String id;
  final String name;

  /// True for coupons (customer attaches a code to the order); false for
  /// auto-apply promotions.
  final bool requiresCoupon;

  const Promotion({
    required this.id,
    required this.name,
    required this.requiresCoupon,
  });

  bool isEligible(Order order);

  /// Applies the promotion and returns the updated order. Implementations
  /// must not mutate [order] — return a new instance ([Order.copyWith]).
  Order apply(Order order);
}
