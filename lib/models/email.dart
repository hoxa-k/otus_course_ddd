class Email {
  final String name;

  Email(this.name) {
    assert(_isValid(), 'Value $name is not valid email');
  }

  final _emailRegex = RegExp(
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
