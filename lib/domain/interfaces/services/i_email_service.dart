import 'package:ddd/domain/models/email.dart';

abstract class IEmailService {
  void sendEmail({required Email to, required String message});
}