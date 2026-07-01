import 'package:ddd/domain/interfaces/repositories/i_order_repository.dart';
import 'package:ddd/domain/models/order_create_exception.dart';

import 'interfaces/handlers/i_domain_event_dispatcher.dart';
import 'models/confirm_order_command.dart';

class ConfirmOrderHandler {
  final IOrderRepository _orderRepository;
  final IDomainEventDispatcher _eventDispatcher;

  ConfirmOrderHandler({
    required IOrderRepository orderRepository,
    required IDomainEventDispatcher eventDispatcher,
  }) : _orderRepository = orderRepository,
       _eventDispatcher = eventDispatcher;

   Future handle(ConfirmOrderCommand command) async {
     final order = _orderRepository.findById(command.orderId);
     if (order == null) throw OrderCreateException('Order not found');
     order.confirm();
     await _orderRepository.save(order);
     _eventDispatcher.dispatch(order.domainEvents);
     order.clearDomainEvents();
  }
}
