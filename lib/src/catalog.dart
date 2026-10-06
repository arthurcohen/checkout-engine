import 'product.dart';

/// The restaurant menu. Do not change it: promotions and tests depend on
/// these ids and prices.
const Map<String, Product> catalog = {
  'burger-small': Product(
    id: 'burger-small',
    name: 'Classic Burger (Small)',
    category: 'burgers',
    priceCents: 699,
  ),
  'burger-medium': Product(
    id: 'burger-medium',
    name: 'Classic Burger (Medium)',
    category: 'burgers',
    priceCents: 949,
  ),
  'burger-large': Product(
    id: 'burger-large',
    name: 'Classic Burger (Large)',
    category: 'burgers',
    priceCents: 1199,
  ),
  'fries-small': Product(
    id: 'fries-small',
    name: 'Small Fries',
    category: 'sides',
    priceCents: 249,
  ),
  'fries-large': Product(
    id: 'fries-large',
    name: 'Large Fries',
    category: 'sides',
    priceCents: 399,
  ),
  'salad': Product(
    id: 'salad',
    name: 'Garden Salad',
    category: 'sides',
    priceCents: 549,
  ),
  'soda': Product(
    id: 'soda',
    name: 'Soda',
    category: 'drinks',
    priceCents: 199,
  ),
  'milkshake': Product(
    id: 'milkshake',
    name: 'Milkshake',
    category: 'drinks',
    priceCents: 449,
  ),
  'coffee': Product(
    id: 'coffee',
    name: 'Coffee',
    category: 'drinks',
    priceCents: 149,
  ),
  'sparkling-water': Product(
    id: 'sparkling-water',
    name: 'Sparkling Water',
    category: 'drinks',
    priceCents: 125,
  ),
  'cookie': Product(
    id: 'cookie',
    name: 'Chocolate Chip Cookie',
    category: 'desserts',
    priceCents: 179,
  ),
  'sundae': Product(
    id: 'sundae',
    name: 'Ice Cream Sundae',
    category: 'desserts',
    priceCents: 329,
  ),
};
