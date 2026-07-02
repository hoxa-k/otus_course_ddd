import 'package:ddd/domain/models/points.dart';

class Product {
  final String id;
  final String name;
  final Points price;
  final String? description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Product && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
