import 'package:dart_frog/dart_frog.dart';
import 'package:delivery_app/src/categories/domain/categories_repo.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;

  final categoriesRepo = context.read<CategoriesRepo>();

  final categorieName = request.uri.queryParameters['name'];

  switch (method) {
    case HttpMethod.get:
      return categoriesRepo.getAllCategories().then((categories) {
        return Response.json(body: {'message': 'Success', 'data': categories});
      }).catchError((error) {
        return Response.json(
          statusCode: 500,
          body: {'message': 'Failed to fetch categories'},
        );
      });

    case HttpMethod.post:
      if (categorieName == null || categorieName.isEmpty) {
        return Response.json(
          statusCode: 400,
          body: {'message': 'Category name is required'},
        );
      }
      return categoriesRepo.addCategory(categorieName).then((_) {
        return Response.json(body: {'message': 'Category added successfully'});
      }).catchError((error) {
        return Response.json(
          statusCode: 500,
          body: {'message': 'Failed to add category'},
        );
      });

    case HttpMethod.delete:
    case HttpMethod.put:
    case HttpMethod.patch:
    case HttpMethod.head:
    case HttpMethod.options:
      return Response.json(
        statusCode: 405,
        body: {'message': 'Method not allowed'},
      );
  }
}
