import 'dart:math';

import '../order.dart';
import '../product.dart';

const burgersCategory = 'burgers';
const drinksCategory = 'drinks';
const dessertsCategory = 'desserts';

/// Distinct products in [order] that have at least one unit, in the order
/// they first appear. Bags may hold the same product on several lines.
List<Product> distinctProducts(Order order) => {
      for (final line in order.lines)
        if (line.quantity > 0) line.product.id: line.product,
    }.values.toList();

/// Distinct products of [category] in [order].
List<Product> productsInCategory(Order order, String category) =>
    distinctProducts(order)
        .where((product) => product.category == category)
        .toList();

/// What it takes to bring [quantity] units priced at [unitPriceCents] down
/// to [floorCents] each; zero when the price is already at or below it.
int priceFloorDiscount(
  int unitPriceCents, {
  required int quantity,
  required int floorCents,
}) =>
    quantity * max(0, unitPriceCents - floorCents);

/// Whether [order] carries the coupon [code], ignoring case and
/// surrounding whitespace.
bool hasCouponCode(Order order, String code) =>
    order.couponCode?.trim().toUpperCase() == code;
