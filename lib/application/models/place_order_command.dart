import 'package:ddd/application/interfaces/i_command.dart';

class PlaceOrderCommand implements ICommand {
  final String id;
  final String orderId;

  const PlaceOrderCommand({required this.id, required this.orderId});
}
