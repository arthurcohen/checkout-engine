import 'catalog.dart';
import 'product.dart';

/// Thrown when a bag receives a product id that is not on the menu.
class UnknownProductException implements Exception {
  final String productId;

  const UnknownProductException(this.productId);

  @override
  String toString() =>
      'UnknownProductException: "$productId" is not in the catalog';
}

class BagItem {
  final String productId;
  final int quantity;

  const BagItem(this.productId, {this.quantity = 1});

  /// Throws [UnknownProductException] when [productId] is not in the
  /// catalog.
  Product get product =>
      catalog[productId] ?? (throw UnknownProductException(productId));
}

/// Throws [UnknownProductException] for an id outside the catalog and
/// [ArgumentError] for a quantity below one.
void validateBagItem(BagItem item) {
  if (!catalog.containsKey(item.productId)) {
    throw UnknownProductException(item.productId);
  }
  if (item.quantity < 1) {
    throw ArgumentError.value(item.quantity, 'quantity', 'must be at least 1');
  }
}

class Bag {
  final List<BagItem> items;

  /// Throws like [validateBagItem] when any of [items] is invalid.
  Bag([List<BagItem>? items]) : items = items ?? <BagItem>[] {
    this.items.forEach(validateBagItem);
  }

  /// Throws like [validateBagItem] and leaves the bag unchanged when the
  /// item is invalid.
  void add(String productId, {int quantity = 1}) {
    final item = BagItem(productId, quantity: quantity);
    validateBagItem(item);
    items.add(item);
  }
}
