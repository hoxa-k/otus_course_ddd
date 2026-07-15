import 'package:ddd/application/interfaces/use_cases/i_submit_order_use_case.dart';
import 'package:ddd/application/models/order_dto.dart';
import 'package:ddd/domain/interfaces/repositories/i_order_repository.dart';
import 'package:ddd/domain/models/order.dart';
import 'package:ddd/domain/models/order_create_exception.dart';

import 'interfaces/handlers/i_domain_event_dispatcher.dart';
import 'interfaces/providers/i_product_info_provider.dart';
import 'models/submit_order_command.dart';

class SubmitOrderHandler implements ISubmitOrderUseCase {
  final IOrderRepository _orderRepository;
  final IProductInfoProvider _productInfoProvider;
  final IDomainEventDispatcher _eventDispatcher;

  SubmitOrderHandler({
    required IOrderRepository orderRepository,
    required IDomainEventDispatcher eventDispatcher,
    required IProductInfoProvider productProvider,
  }) : _orderRepository = orderRepository,
        _productInfoProvider = productProvider,
       _eventDispatcher = eventDispatcher;

   @override
  Future<OrderDto> handle(SubmitOrderCommand command) async {
     final order = Order.createNew(customerId: command.customerId);

     for (final orderLine in command.items) {
       final product = _productInfoProvider.findById(orderLine.productId)?.toDomain();
       if (product == null) throw OrderCreateException('Product ${orderLine.productId} not found');
       order.addItem(product, orderLine.quantity);
     }
     order.submit();
     await _orderRepository.save(order);
     _eventDispatcher.dispatch(order.domainEvents);
     order.clearDomainEvents();
     return OrderDto.fromDomain(order);
  }
}
