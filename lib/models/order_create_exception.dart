class OrderCreateException implements Exception {
  final String message;

  OrderCreateException(this.message);

  @override
  String toString() {
    return 'Order create exception: $message';
  }
}
