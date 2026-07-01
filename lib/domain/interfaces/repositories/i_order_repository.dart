import 'package:ddd/domain/models/order.dart';

abstract class IOrderRepository {
  Order? findById(String id);
  List<Order> findByCustomerId(String customerId);
  Future<Order> save(Order order);
}