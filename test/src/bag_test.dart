import 'package:checkout_engine/checkout_engine.dart';
import 'package:test/test.dart';

void main() {
  group('BagItem', () {
    test('can be const and resolves its product from the catalog', () {
      const item = BagItem('soda');

      expect(item.product, catalog['soda']);
    });

    test('throws UnknownProductException when reading an unknown product', () {
      expect(
        () => const BagItem('pizza').product,
        throwsA(
          isA<UnknownProductException>()
              .having((error) => error.productId, 'productId', 'pizza'),
        ),
      );
    });
  });

  group('Bag quantity', () {
    test('add rejects zero', () {
      expect(() => Bag().add('soda', quantity: 0), throwsArgumentError);
    });

    test('add rejects negative quantities', () {
      expect(
        () => Bag().add('burger-small', quantity: -2),
        throwsArgumentError,
      );
    });

    test('add keeps the bag intact after a bad quantity', () {
      final bag = Bag()..add('soda');

      expect(() => bag.add('fries-small', quantity: 0), throwsArgumentError);
      expect(bag.items, hasLength(1));
    });

    test('the constructor rejects a bad quantity', () {
      expect(
        () => Bag([const BagItem('soda', quantity: 0)]),
        throwsArgumentError,
      );
    });
  });

  group('Order.fromBag', () {
    test('rejects items slipped into the list after construction', () {
      final bag = Bag()..add('soda');
      bag.items.add(const BagItem('coffee', quantity: -1));

      expect(() => Order.fromBag(bag), throwsArgumentError);
    });
  });

  group('Bag', () {
    test('add throws for an unknown product and keeps the bag intact', () {
      final bag = Bag()..add('soda');

      expect(() => bag.add('pizza'), throwsA(isA<UnknownProductException>()));
      expect(bag.items, hasLength(1));
    });

    test('rejects an unknown product passed to the constructor', () {
      expect(
        () => Bag([const BagItem('soda'), const BagItem('pizza')]),
        throwsA(isA<UnknownProductException>()),
      );
    });
  });

  group('UnknownProductException', () {
    test('names the unknown id in its message', () {
      expect(
        const UnknownProductException('pizza').toString(),
        contains('pizza'),
      );
    });
  });
}
