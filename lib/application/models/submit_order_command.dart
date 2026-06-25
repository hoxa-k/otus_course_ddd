import 'package:ddd/application/interfaces/i_command.dart';

import 'order_line_dto.dart';

class SubmitOrderCommand implements ICommand {
  final String id;
  final String customerId;
  final List<OrderLineDto> items;

  const SubmitOrderCommand({
    required this.id,
    required this.customerId,
    required this.items,
  });
}
