import 'dart:collection';

import 'package:ddd/domain/events/order_confirmed_event.dart';
import 'package:uuid/uuid.dart';

import 'domain_events_mixin.dart';
import 'order_create_exception.dart';
import 'order_line.dart';
import 'product.dart';

enum OrderStatus { draft, created, confirmed, paid }

class Order with DomainEventsMixin {
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

  void submit() {
    if (_status != .draft) {
      throw OrderCreateException('Заказ в статусе $_status не может быть создан');
    }
    final totalProductsCount = _orderLines.isEmpty ? 0 : _orderLines
        .map((e) => e.quantity)
        .reduce((prev, next) => prev + next);
    if (totalProductsCount <= 0) {
      throw OrderCreateException('В заказе должен быть хотябы один продукт');
    }
    _status = .created;
  }

  void confirm() {
    if (_status != .created) {
      throw OrderCreateException(
        'Заказ в статусе $_status не может быть подтвержден',
      );
    }
    _status = .confirmed;
    addDomainEvent(
      OrderConfirmedEvent(
        eventId: Uuid().v4(),
        orderId: _id,
        customerId: customerId,
        occurredAt: DateTime.now(),
      ),
    );
  }

  bool _isContainProduct(Product product) {
    for (final orderLine in _orderLines) {
      if (orderLine.productId == product.id) return true;
    }
    return false;
  }
}
