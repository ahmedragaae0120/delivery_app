import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:delivery_app/src/auth/domain/auth_repository.dart';
import 'package:delivery_app/src/auth/data/auth_repository_impl.dart';
import 'package:delivery_app/src/categories/domain/categories_repo.dart';
import 'package:delivery_app/src/categories/data/categories_repo_impl.dart';
import 'package:delivery_app/src/dataBase/database_client.dart';
import 'package:delivery_app/src/products/domain/product_repository.dart';
import 'package:delivery_app/src/products/data/product_repository_impl.dart';
import 'package:dotenv/dotenv.dart';

/// يتم إنشاء الـ instance هنا مرة واحدة فقط عند تشغيل السيرفر
final _dbClient = DataBaseClient();
final productRepo = ProductRepositoryImpl(_dbClient);
final categoriesRepo = CategoriesRepoImpl(_dbClient);
final authRepo = AuthRepositoryImpl(_dbClient);

Handler middleware(Handler handler) {
  return handler
      .use(
        provider<CategoriesRepo>((context) => categoriesRepo),
      )
      .use(
        provider<ProductsRepository>((context) => productRepo),
      )
      .use(
        provider<AuthRepository>((context) => authRepo),
      )
      .use(provider<DataBaseClient>((context) => _dbClient))
      .use(_authMiddleware);
}

Handler _authMiddleware(Handler handler) {
  final env = DotEnv()..load();
  final secretKey = env['JWT_SECRET_KEY'] ?? '';
  return (context) async {
    final request = context.request;

    final path = request.uri.path;

    if (path.startsWith('/auth/login') ||
        path.startsWith('/auth/signup') ||
        path.startsWith('/products') ||
        path.startsWith('/auth/refresh') ||
        path.startsWith('/categories')) {
      return handler(context);
    }

    final authHeader = request.headers['authorization'];

    // ❌ مفيش token
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(
        statusCode: 401,
        body: {'message': 'Unauthorized'},
      );
    }

    try {
      final token = authHeader.split(' ').last;

      final jwt = JWT.verify(
        token,
        SecretKey(secretKey),
      );

      final payload = jwt.payload as Map<String, dynamic>;

      // ✅ نضيف user في context
      final updatedContext = context.provide(() => payload);

      return handler(updatedContext);
    } catch (e) {
      return Response.json(
        statusCode: 401,
        body: {'message': 'Invalid or expired token'},
      );
    }
  };
}
