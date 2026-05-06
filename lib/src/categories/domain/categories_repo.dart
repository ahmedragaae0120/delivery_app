import 'package:delivery_app/model/category_model.dart';

/// CategoriesRepo
abstract class CategoriesRepo {
  /// getAllCategories
  Future<List<CategoryModel>> getAllCategories();

  /// addCategory
  Future<void> addCategory(String name);
}
