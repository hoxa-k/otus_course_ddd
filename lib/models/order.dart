import 'order_line.dart';
import 'product.dart';

class Order {
  static const maxPositionsCount = 10;
  final String id;
  final List<OrderLine> _orderLines = [];
  final String customerId;

  Order({
    required this.id,
    required this.customerId,
  });

  List<OrderLine> get items => _orderLines;

  void addItem(Product product, int quantity) {
    final bool isContainProduct = _isContainProduct(product);
    if (_orderLines.length >= 10 && !isContainProduct) {
      throw Exception(
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
