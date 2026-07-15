import 'package:ddd/application/models/product_dto.dart';

abstract class IProductInfoProvider {
  ProductDto? findById(String id);
}