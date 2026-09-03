import '../models/product_model.dart';
abstract class ProductRepository {
  Future<List<ProductModel>> getAllProducts({
    int page = 1,
    int limit = 100,
  });
}