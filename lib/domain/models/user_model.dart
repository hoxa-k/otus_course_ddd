class UserModel {
  String id;
  String name;
  String surname;
  String email;
  double balance;

  UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    this.balance = 0,
  });

  String get fullName => '$name $surname';

  void changeBalance(double balanceInc) {
    balance = balance + balanceInc;
  }
}
