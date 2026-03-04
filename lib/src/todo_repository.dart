import 'package:dart_frog/dart_frog.dart';
import 'package:delivery_app/model/product_model.dart';

/// TodoRepository
abstract class ProductsRepository {
  /// getAll
  Future<List<ProductModel>> getAll({
    required int limit,
    required int offset,
    bool? isCompleted,
  });

  /// getById
  Future<ProductModel> getById(String id);

  /// create
  Future<void> create(
    ProductModel product,
    String mimeType,
    UploadedFile image,
  );

  /// update
  Future<void> update(String id, ProductModel product);

  /// delete
  Future<void> delete(String id);
}
