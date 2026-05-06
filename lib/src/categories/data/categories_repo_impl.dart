import 'package:delivery_app/model/category_model.dart';
import 'package:delivery_app/src/categories/domain/categories_repo.dart';
import 'package:delivery_app/src/dataBase/database_client.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

/// CategoriesRepoImpl
class CategoriesRepoImpl implements CategoriesRepo {
  /// CategoriesRepoImpl
  const CategoriesRepoImpl(this._db);

  final DataBaseClient _db;
  static const _uuid = Uuid();
  @override
  Future<void> addCategory(String name) {
    final id = _uuid.v1();
    return _db.connection.execute(
      Sql.named('''
        INSERT INTO public.categories (id, name)
        VALUES (@id, @name);
      '''),
      parameters: {
        'id': id,
        'name': name,
      },
    );
  }

  @override
  Future<List<CategoryModel>> getAllCategories() {
    return _db.connection
        .execute(
      Sql.named('SELECT * FROM public.categories'),
    )
        .then((result) {
      return result
          .map((row) => CategoryModel.fromColumnMap(row.toColumnMap()))
          .toList();
    });
  }
}
