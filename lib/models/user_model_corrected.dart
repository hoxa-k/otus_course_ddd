import 'package:ddd/models/points.dart';
import 'package:ddd/models/email.dart';

class UserModel {
  final String id;
  String name;
  String surname;
  Email email;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
  });

  String get fullName => '$name $surname';
}

class GameParticipantModel {
  final UserModel user;
  Points _balance = Points(0);

  GameParticipantModel({required this.user});

  void changeBalance(int balanceInc) {
    _balance = _balance.add(balanceInc);
  }

  Points get balance => _balance;
}
