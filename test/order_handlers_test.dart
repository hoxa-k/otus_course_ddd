import 'dart:async';

import 'package:ddd/application/confirm_order_handler.dart';
import 'package:ddd/application/interfaces/i_command.dart';
import 'package:ddd/application/interfaces/providers/i_product_info_provider.dart';
import 'package:ddd/application/models/confirm_order_command.dart';
import 'package:ddd/application/models/order_line_dto.dart';
import 'package:ddd/application/models/product_dto.dart';
import 'package:ddd/application/models/submit_order_command.dart';
import 'package:ddd/application/send_order_confirmation_handler.dart';
import 'package:ddd/application/submit_order_handler.dart';
import 'package:ddd/domain/interfaces/repositories/i_order_repository.dart';
import 'package:ddd/domain/interfaces/services/i_email_service.dart';
import 'package:ddd/domain/models/email.dart';
import 'package:ddd/domain/models/order.dart';
import 'package:ddd/infrastructure/in_process_domain_event_dispatcher.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

class MockEmailService extends Mock implements IEmailService {}

class MockProductProvider extends Mock implements IProductInfoProvider {}

class FakeOrder extends Fake implements Order {
  @override
  void confirm() {
    // TODO: implement confirm
  }

  @override
  void submit() {
    // TODO: implement submit
  }
}

class FakeEmail extends Fake implements Email {}

void main() {
  late StreamController<ICommand> streamController;
  late Stream<ICommand> stream;
  late Order order;
  late ProductDto product;

  setUpAll(() {
    registerFallbackValue(FakeEmail());
  });

  setUp(() {
    streamController = StreamController<ICommand>.broadcast();
    stream = streamController.stream;
    order = Order.create(
      id: 'id',
      customerId: 'customerId',
      status: .created,
    );
    registerFallbackValue(order);

    product = ProductDto(id: '123', name: 'name', price: 345);
    registerFallbackValue(product);
  });

  tearDown(() {
    streamController.close();
  });

  group('Submit order command tests', () {
    const testCustomerId = '123qwe';

    test('Order confirmation test', () {
      final IOrderRepository orderRepository = MockOrderRepository();
      when(() => orderRepository.save(any())).thenAnswer((_) async {
        return order;
      });
      when(() => orderRepository.findById(any())).thenAnswer((_) {
        return order;
      });
      final IProductInfoProvider productInfoProvider = MockProductProvider();
      when(() => productInfoProvider.findById(any())).thenAnswer((_) {
        return product;
      });

      final IEmailService emailService = MockEmailService();
      when(
        () => emailService.sendEmail(
          to: any(named: 'to'),
          message: any(named: 'message'),
        ),
      ).thenAnswer((_) {});

      stream.where((event) => event is SubmitOrderCommand).listen((event) async {
        final submitOrderCommand = event as SubmitOrderCommand;
       await  SubmitOrderHandler(
          orderRepository: orderRepository,
          productProvider: productInfoProvider,
          eventDispatcher: InProcessDomainEventDispatcher(eventHandlers: []),
        ).handle(submitOrderCommand);

        verify(() => productInfoProvider.findById(any())).called(1);
        verify(() => orderRepository.save(any())).called(1);
      });

      stream.where((event) => event is ConfirmOrderCommand).listen((event) async {
        final confirmOrderCommand = event as ConfirmOrderCommand;
        await ConfirmOrderHandler(
          orderRepository: orderRepository,
          eventDispatcher: InProcessDomainEventDispatcher(
            eventHandlers: [
              SendOrderConfirmationHandler(emailService: emailService),
            ],
          ),
        ).handle(confirmOrderCommand);

        verify(() => orderRepository.save(any())).called(1);
        verify(
              () => emailService.sendEmail(
            to: any(named: "to"),
            message: any(named: "message"),
          ),
        ).called(1);
      });

      streamController.sink.add(
        SubmitOrderCommand(
          id: '111',
          customerId: testCustomerId,
          items: [OrderLineDto(productId: 'product1', quantity: 1)],
        ),
      );

      streamController.sink.add(
        ConfirmOrderCommand(id: '112', orderId: 'order1'),
      );
    });
  });

}