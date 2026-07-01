import 'package:ddd/models/order.dart';

abstract class IOrderRepository {
  Order? findById(String id);
  List<Order> findByCustomerId(String customerId);
  Order save(Order order);
}