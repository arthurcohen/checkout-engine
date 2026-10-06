import 'dart:math';

import 'bag.dart';
import 'money.dart';
import 'product.dart';

class OrderLine {
  final Product product;
  final int quantity;

  const OrderLine(this.product, {required this.quantity});

  int get lineTotalCents => product.priceCents * quantity;

  @override
  String toString() => '${quantity}x ${product.name}';
}

/// A promotion that made it onto the order, with how much it took off.
class AppliedPromotion {
  final String id;
  final String name;
  final int discountCents;

  const AppliedPromotion({
    required this.id,
    required this.name,
    required this.discountCents,
  });

  @override
  bool operator ==(Object other) =>
      other is AppliedPromotion &&
      other.id == id &&
      other.name == name &&
      other.discountCents == discountCents;

  @override
  int get hashCode => Object.hash(id, name, discountCents);

  @override
  String toString() => '$name (-$discountCents)';
}

/// All money values are integer cents (699 means $6.99).
///
/// The totals getters below are the single source of truth for money
/// math — every checkout path must compute totals through them.
/// `discountCents` is what drives totals; `lineDiscountCents` is purely
/// informational (how much is already off each line) and does not feed
/// the totals getters.
class Order {
  final List<OrderLine> lines;

  /// Coupon code attached by the customer, if any (e.g. "SAVE5").
  final String? couponCode;

  /// Total discount applied to this order, in cents.
  final int discountCents;

  /// Discount attributed to individual product lines, keyed by product id
  /// (total for the line, all units). Deals that target specific lines —
  /// e.g. a price-point deal on one product — record their discount here
  /// so other line-aware deals can account for what is already off.
  final Map<String, int> lineDiscountCents;

  /// Promotions applied to this order, in the order they were applied.
  /// Their discounts add up to [discountCents] as long as every discount
  /// came in through [withPromotion]; [withDiscount] and [copyWith] do not
  /// record anything.
  final List<AppliedPromotion> appliedPromotions;

  Order({
    required List<OrderLine> lines,
    this.couponCode,
    this.discountCents = 0,
    Map<String, int>? lineDiscountCents,
    List<AppliedPromotion>? appliedPromotions,
  })  : lines = List.unmodifiable(lines),
        lineDiscountCents = Map.unmodifiable(lineDiscountCents ?? const {}),
        appliedPromotions = List.unmodifiable(appliedPromotions ?? const []);

  /// Throws like [validateBagItem] when an invalid item was added to
  /// [Bag.items] directly.
  factory Order.fromBag(Bag bag, {String? couponCode}) {
    bag.items.forEach(validateBagItem);
    final lines = bag.items
        .map((item) => OrderLine(item.product, quantity: item.quantity))
        .toList();
    return Order(lines: lines, couponCode: couponCode);
  }

  int get subtotalCents =>
      lines.fold(0, (sum, line) => sum + line.lineTotalCents);

  /// What the customer pays before tax: the subtotal after every discount,
  /// never below zero.
  int get discountedSubtotalCents => max(0, subtotalCents - discountCents);

  /// The city charges 8.75% sales tax on what the customer actually pays,
  /// rounded half-up.
  int get taxCents {
    const taxRateBps = 875;
    return percentOfCents(discountedSubtotalCents, taxRateBps);
  }

  int get totalCents => discountedSubtotalCents + taxCents;

  /// Units of [productId] across every line of the order.
  int quantityOf(String productId) => lines
      .where((line) => line.product.id == productId)
      .fold(0, (sum, line) => sum + line.quantity);

  /// Records a promotion and adds its discount in one step:
  /// [orderDiscountCents] off the order as a whole plus every entry of
  /// [lineDiscountCents] off that product's line. The recorded amount is
  /// their sum.
  Order withPromotion({
    required String id,
    required String name,
    int orderDiscountCents = 0,
    Map<String, int> lineDiscountCents = const {},
  }) {
    final discounted = lineDiscountCents.entries.fold(
      withDiscount(orderDiscountCents),
      (order, entry) => order.withDiscount(entry.value, productId: entry.key),
    );
    return discounted.copyWith(
      appliedPromotions: [
        ...appliedPromotions,
        AppliedPromotion(
          id: id,
          name: name,
          discountCents: discounted.discountCents - discountCents,
        ),
      ],
    );
  }

  /// Adds [cents] to the order discount and, when [productId] is given,
  /// to that product's entry in [lineDiscountCents]. Low-level: prefer
  /// [withPromotion], which also records the promotion.
  Order withDiscount(int cents, {String? productId}) {
    final lineDiscounts = {...lineDiscountCents};
    if (productId != null) {
      lineDiscounts.update(
        productId,
        (current) => current + cents,
        ifAbsent: () => cents,
      );
    }
    return copyWith(
      discountCents: discountCents + cents,
      lineDiscountCents: lineDiscounts,
    );
  }

  /// [lineDiscountCents] and [appliedPromotions], if given, replace the
  /// whole collection.
  Order copyWith({
    String? couponCode,
    int? discountCents,
    Map<String, int>? lineDiscountCents,
    List<AppliedPromotion>? appliedPromotions,
  }) {
    return Order(
      lines: lines,
      couponCode: couponCode ?? this.couponCode,
      discountCents: discountCents ?? this.discountCents,
      lineDiscountCents: lineDiscountCents ?? this.lineDiscountCents,
      appliedPromotions: appliedPromotions ?? this.appliedPromotions,
    );
  }

  @override
  String toString() => 'Order(lines: $lines, coupon: $couponCode, '
      'subtotal: $subtotalCents, discount: $discountCents, '
      'promotions: $appliedPromotions, '
      'tax: $taxCents, total: $totalCents)';
}
