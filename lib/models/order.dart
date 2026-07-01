import 'dart:collection';

import 'package:uuid/uuid.dart';

import 'order_create_exception.dart';
import 'order_line.dart';
import 'product.dart';

enum OrderStatus { draft, created, confirmed, paid }

class Order {
  static const maxPositionsCount = 10;
  late OrderStatus _status;
  late String _id;
  late String _customerId;
  final List<OrderLine> _orderLines = [];

  String? get id => _id;

  String get customerId => _customerId;

  OrderStatus get status => _status;

  List<OrderLine> get items => UnmodifiableListView(_orderLines);

  Order._({
    required String id,
    required String customerId,
    required OrderStatus status,
  }) {
    _id = id;
    _customerId = customerId;
    _status = status;
  }

  static Order createNew({required String customerId}) {
    final id = Uuid().v4();
    return Order._(id: id, customerId: customerId, status: .draft);
  }

  static Order create({
    required String id,
    required String customerId,
    required OrderStatus status,
  }) {
    return Order._(id: id, customerId: customerId, status: status);
  }

  void addItem(Product product, int quantity) {
    final bool isContainProduct = _isContainProduct(product);
    if (_orderLines.length >= 10 && !isContainProduct) {
      throw OrderCreateException(
        'В заказ нельзя добавить больше $maxPositionsCount позиций',
      );
    }

    final orderLine = OrderLine(productId: product.id, quantity: quantity);
    if (isContainProduct) {
      final productIndex = _orderLines.indexWhere(
        (e) => e.productId == product.id,
      );
      if (productIndex >= 0) _orderLines.removeAt(productIndex);
      _orderLines.insert(productIndex, orderLine);
    } else {
      _orderLines.add(orderLine);
    }
  }

  bool _isContainProduct(Product product) {
    for (final orderLine in _orderLines) {
      if (orderLine.productId == product.id) return true;
    }
    return false;
  }
}
