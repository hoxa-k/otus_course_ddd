import 'package:ddd/application/interfaces/i_command.dart';

class ConfirmOrderCommand implements ICommand {
  final String id;
  final String orderId;

  const ConfirmOrderCommand({required this.id, required this.orderId});
}
