/// A product that can be sold by the restaurant.
class Product {
  final String id;
  final String name;

  /// Menu section: burgers, sides, drinks or desserts.
  final String category;

  /// Price in cents; 699 means $6.99.
  final int priceCents;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.priceCents,
  });

  @override
  String toString() => '$name (\$$priceCents)';
}
