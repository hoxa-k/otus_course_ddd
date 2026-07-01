import 'package:ddd/infrastructure/repositories/in_memory_order_repository.dart';
import 'package:ddd/models/order.dart';
import 'package:ddd/models/order_create_exception.dart';
import 'package:ddd/models/points.dart';
import 'package:ddd/models/product.dart';
import 'package:test/test.dart';

void main() {
  group('Order aggregate tests', () {
    const testCustomerId = '123qwe';
    final products = List.generate(
      20,
      (i) => Product(id: '123$i', name: 'name $i', price: Points(100 + i * 10)),
    );

    test('Order creation test', () {
      final order = Order.createNew(customerId: testCustomerId);

      order.addItem(products[0], 1);
      order.addItem(products[1], 5);

      final repository = InMemoryOrderRepository();
      repository.save(order);

      final orders = repository.findByCustomerId(testCustomerId);
      expect(orders.length, 1);
      final savedOrder = orders.first;
      expect(savedOrder.id, order.id);
      expect(savedOrder.status, order.status);
      expect(savedOrder.customerId, order.customerId);
    });

    test('Order creation test with more then 10 positions', () {
      final order = Order.createNew(customerId: testCustomerId);

      for (int i = 0; i < 10; i++) {
        order.addItem(products[i], 1);
      }

      expect(
        () => order.addItem(products[10], 1),
        throwsA(
          predicate(
            (e) =>
                e is OrderCreateException &&
                e.message ==
                    'В заказ нельзя добавить больше ${Order.maxPositionsCount} позиций',
          ),
        ),
      );
    });
  });
}
