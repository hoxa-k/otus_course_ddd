import 'package:ddd/application/interfaces/handlers/i_domain_event_handler.dart';
import 'package:ddd/domain/events/order_confirmed_event.dart';
import 'package:ddd/domain/interfaces/services/i_email_service.dart';
import 'package:ddd/domain/models/email.dart';

class SendOrderConfirmationHandler
    implements IDomainEventHandler<OrderConfirmedEvent> {
  final IEmailService emailService;

  SendOrderConfirmationHandler({required this.emailService});

  @override
  Future<void> handle(OrderConfirmedEvent domainEvent) async {
    final userEmail = Email('${domainEvent.customerId}@mail.ru');
    final message =
        'The order ${domainEvent.orderId} was confirmed successfully';
    emailService.sendEmail(to: userEmail, message: message);
  }
}
