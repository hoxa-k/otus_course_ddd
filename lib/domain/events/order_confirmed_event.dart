import 'package:ddd/domain/events/domain_event.dart';

class OrderConfirmedEvent implements IDomainEvent {
  @override
  final String eventId;
  final String orderId;
  final String customerId;
  @override
  final DateTime occurredAt;

  const OrderConfirmedEvent({
    required this.eventId,
    required this.orderId,
    required this.customerId,
    required this.occurredAt,
  });
}
