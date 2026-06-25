class Email {
  final String name;

  const Email._(this.name);

  factory Email(String name) {
    final email = Email._(name);
    if (!email._isValid()) {
      throw FormatException('Value $name is not valid email');
    }
    return email;
  }

  RegExp get _emailRegex => RegExp(
    "^[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+\$",
  );

  bool _isValid() {
    return _emailRegex.hasMatch(name);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Email && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return '$runtimeType ($name)';
  }
}
