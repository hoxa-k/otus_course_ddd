import 'package:ddd/domain/interfaces/repositories/i_order_repository.dart';
import 'package:ddd/domain/models/order.dart';
import 'package:ddd/domain/models/points.dart';
import 'package:ddd/domain/models/product.dart';

import 'interfaces/handlers/i_domain_event_dispatcher.dart';
import 'models/submit_order_command.dart';

class SubmitOrderHandler {
  final IOrderRepository _orderRepository;
  final IDomainEventDispatcher _eventDispatcher;

  SubmitOrderHandler({
    required IOrderRepository orderRepository,
    required IDomainEventDispatcher eventDispatcher,
  }) : _orderRepository = orderRepository,
       _eventDispatcher = eventDispatcher;

   Future handle(SubmitOrderCommand command) async {
     final order = Order.createNew(customerId: command.customerId);

     for (final orderLine in command.items) {
       //TODO get products by id from product repository
       final product = Product(id: orderLine.productId, name: 'name', price: Points(123));
       order.addItem(product, orderLine.quantity);
     }
     order.submit();
     await _orderRepository.save(order);
     _eventDispatcher.dispatch(order.domainEvents);
     order.clearDomainEvents();
  }
}
