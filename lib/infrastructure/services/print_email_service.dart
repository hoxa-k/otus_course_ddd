import 'package:ddd/domain/interfaces/services/i_email_service.dart';
import 'package:ddd/domain/models/email.dart';

class PrintEmailService implements IEmailService{
  @override
  void sendEmail({required Email to, required String message}){
      print('Send email to ${to.toString()} with message: "$message"');
  }
}