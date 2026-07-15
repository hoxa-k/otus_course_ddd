import 'package:ddd/domain/models/order_line.dart';

class OrderLineDto {
  final String productId;
  final int quantity;

  const OrderLineDto({required this.productId, required this.quantity});

  static OrderLineDto fromDomain(OrderLine orderLine) {
    return OrderLineDto(
      productId: orderLine.productId,
      quantity: orderLine.quantity,
    );
  }
}
