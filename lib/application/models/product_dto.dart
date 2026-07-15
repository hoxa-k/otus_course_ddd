import 'package:ddd/domain/models/points.dart';
import 'package:ddd/domain/models/product.dart';

class ProductDto {
  final String id;
  final String name;
  final String? description;
  final num price;

  const ProductDto({
    required this.id,
    required this.name,
    this.description,
    required this.price,
  });

  static ProductDto fromDomain(Product product) {
    return ProductDto(
      id: product.id,
      name: product.name,
      price: product.price.count,
    );
  }

  Product toDomain() {
    return Product(id: id, name: name, price: Points(price.toInt()));
  }
}
