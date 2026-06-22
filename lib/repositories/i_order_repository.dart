import 'package:ddd/models/order.dart';

abstract class IOrderRepository {
  Order findById(String id);
  Order findByCustomerId(String customerId);
}