import 'package:dart_frog/dart_frog.dart';
import 'package:delivery_app/model/product_model.dart';
import 'package:delivery_app/src/dataBase/database_client.dart';
import 'package:delivery_app/src/dataBase/supabase_service.dart';
import 'package:delivery_app/src/products/domain/product_repository.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

/// ProductRepositoryImpl
class ProductRepositoryImpl implements ProductsRepository {
  /// ProductRepositoryImpl
  ProductRepositoryImpl(this._db);
  final DataBaseClient _db;
  static const _uuid = Uuid();
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Future<void> create(
    ProductModel product,
    String mimeType,
    UploadedFile image,
  ) async {
    final id = _uuid.v4();
    final imageUrl = await _supabaseService.uploadProductImage(
      id: id,
      mimeType: mimeType,
      image: image,
    );

    await _db.connection.execute(
      Sql.named('''
        INSERT INTO public.products (id, name, description, price, rating, image, category_id)
        VALUES (@id, @name, @description, @price, @rating, @image, @category_id);
      '''),
      parameters: {
        'id': id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'rating': product.rating,
        'image': imageUrl,
        'category_id': product.categoryId,
      },
    );
  }

  @override
  Future<void> delete(String id) {
    return _db.connection.execute(
      Sql.named('''
        DELETE FROM public.products WHERE id = @id;
      '''),
      parameters: {
        'id': id,
      },
    );
  }

  @override
  Future<List<ProductModel>> getAll({
    required int limit,
    required int offset,
    String? categoryId,
  }) async {
    final result = await _db.connection.execute(
      Sql.named('''
       SELECT p.id, 
       p.name, 
       description, 
       image, 
       rating, 
       price,
       category_id, 
       json_build_object(
        'id', c.id,
        'name', c.name
       ) as category
	     FROM public.products p
	     Left JOIN public.categories c on p.category_id = c.id
       WHERE c.id = @categoryId OR @categoryId IS NULL
       LIMIT @limit OFFSET @offset;
      '''),
      parameters: {
        'limit': limit,
        'offset': offset,
        'categoryId': categoryId,
      },
    );

    final products = result
        .map((row) => ProductModel.fromColumnMap(row.toColumnMap()))
        .toList();
    return products;
  }

  @override
  Future<ProductModel?> getById(String id) async {
    final result = await _db.connection.execute(
      Sql.named('''
       SELECT p.id, 
       p.name, 
       description, 
       image, 
       rating, 
       price,
       category_id, 
       json_build_object(
        'id', c.id,
        'name', c.name
       ) as category
       FROM public.products p
       Left JOIN public.categories c on p.category_id = c.id
       WHERE p.id = @id;
      '''),
      parameters: {
        'id': id,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    final product = ProductModel.fromColumnMap(result.first.toColumnMap());
    return product;
  }

  @override
  Future<void> update(
    String id,
    ProductModel product,
    String mimeType,
    UploadedFile? image,
  ) async {
    final imageUrl = image != null
        ? await _supabaseService.uploadProductImage(
            id: id,
            mimeType: mimeType,
            image: image,
          )
        : product.imageUrl;

    await _db.connection.execute(
      Sql.named('''
        UPDATE public.products
        SET name = @name,
            description = @description,
            image = @image,
            price = @price,
            rating = @rating,
            category_id = @category_id
        WHERE id = @id;
      '''),
      parameters: {
        'id': id,
        'name': product.name,
        'description': product.description,
        'image': imageUrl,
        'price': product.price,
        'rating': product.rating,
        'category_id': product.categoryId,
      },
    );
  }
}
