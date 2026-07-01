import 'package:ddd/domain/interfaces/repositories/i_order_repository.dart';
import 'package:ddd/domain/models/order.dart';

class InMemoryOrderRepository implements IOrderRepository {
  final List<Order> _orders = [];

  @override
  List<Order> findByCustomerId(String customerId) {
    return _orders.where((e) => e.customerId == customerId).toList();
  }

  @override
  Order? findById(String id) {
    try {
      return _orders.firstWhere((e) => e.id == id);
    } catch (e) {
      throw Exception('Order with id $id not found');
    }
  }

  @override
  Future<Order> save(Order order) async {
    final index = _orders.indexWhere((e) => e.id == order.id);
    final insertTo = index < 0 ? _orders.length : index;
    if (index >= 0) _orders.removeAt(index);
    _orders.insert(insertTo, order);
    return _orders[insertTo];
  }
}
