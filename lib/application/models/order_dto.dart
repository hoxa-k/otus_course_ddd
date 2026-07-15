import 'package:ddd/application/models/order_line_dto.dart';
import 'package:ddd/domain/models/order.dart';

class OrderDto {
  final String? orderId;
  final String status;
  final List<OrderLineDto> orderLines;

  const OrderDto({
    required this.orderId,
    required this.status,
    required this.orderLines,
  });

  static OrderDto fromDomain(Order order) {
    return OrderDto(
      orderId: order.id,
      status: order.status.name,
      orderLines: order.items.map((e) => OrderLineDto.fromDomain(e)).toList(),
    );
  }
}
