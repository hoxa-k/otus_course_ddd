class OrderLineDto {
  final String productId;
  final int quantity;

  const OrderLineDto({
    required this.productId,
    required this.quantity,
  });
}