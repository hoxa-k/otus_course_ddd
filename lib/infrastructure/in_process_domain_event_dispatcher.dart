import 'package:ddd/application/interfaces/handlers/i_domain_event_dispatcher.dart';
import 'package:ddd/application/interfaces/handlers/i_domain_event_handler.dart';
import 'package:ddd/domain/events/domain_event.dart';
import 'package:ddd/domain/events/order_confirmed_event.dart';

class InProcessDomainEventDispatcher implements IDomainEventDispatcher {
  final List<IDomainEventHandler<OrderConfirmedEvent>> _eventHandlers;

  InProcessDomainEventDispatcher({
    required List<IDomainEventHandler<OrderConfirmedEvent>> eventHandlers,
  }) : _eventHandlers = eventHandlers;

  @override
  Future<dynamic> dispatch(List<IDomainEvent> events) async {
    final domainEvents = List.from(events);
    for (final domainEvent in domainEvents) {
      switch (domainEvent) {
        case OrderConfirmedEvent orderConfirmedEvent:
          for (final e in _eventHandlers) {
            await e.handle(orderConfirmedEvent);
          }
      }
    }
  }
}
