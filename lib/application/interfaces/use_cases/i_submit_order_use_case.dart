import 'package:ddd/application/models/order_dto.dart';
import 'package:ddd/application/models/submit_order_command.dart';

abstract class ISubmitOrderUseCase {
  Future<OrderDto> handle(SubmitOrderCommand command);
}