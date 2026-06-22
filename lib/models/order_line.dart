import 'package:ddd/models/product.dart';

class OrderLine {
  final String productId;
  final int quantity;

  const OrderLine({
    required this.productId,
    required this.quantity,
  });

  OrderLine changeQuantity(int quantity) {
    if (quantity <= 0) throw Exception('');
    return OrderLine(productId: productId, quantity: this.quantity + quantity);
  }

  OrderLine decreaseQuantity(int quantity) {
    return OrderLine(productId: productId, quantity: this.quantity + quantity);
  }
}
