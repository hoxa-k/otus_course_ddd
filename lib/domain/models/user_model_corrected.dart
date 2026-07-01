import 'package:ddd/domain/models/points.dart';
import 'package:ddd/domain/models/email.dart';

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

enum GameParticipantStatus { beginner, advanced, master }

class GameParticipantModel {
  final UserModel user;
  Points _balance = Points(0);
  late GameParticipantStatus _status;

  Points get balance => _balance;

  GameParticipantStatus get status => _status;

  GameParticipantModel._({required this.user, required Points balance}) {
    _balance = balance;
    _changeStatus();
  }

  static GameParticipantModel create({
    required UserModel user,
    Points balance = const Points.zero(),
  }) {
    return GameParticipantModel._(user: user, balance: balance);
  }

  void changeBalance(int balanceInc) {
    _balance = _balance.add(balanceInc);
    _changeStatus();
  }

  void _changeStatus() {
    switch (_balance.count) {
      case >= 100 && <= 1000:
        _status = .advanced;
        break;
      case > 1000:
        _status = .master;
        break;
      default:
        _status = .beginner;
    }
  }
}
