import 'package:dart_frog/dart_frog.dart';
import 'package:delivery_app/model/product_model.dart';
import 'package:delivery_app/src/products/domain/product_repository.dart';
import 'package:mime/mime.dart';

Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  final method = request.method;
  final productRepo = context.read<ProductsRepository>();

  final page = int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
  final limit =
      int.tryParse(request.uri.queryParameters['limit'] ?? '10') ?? 10;
  final categoryId = request.uri.queryParameters['categoryId'];

  final offset = (page - 1) * limit;

  switch (method) {
    case HttpMethod.get:
      final result = await productRepo.getAll(
        limit: limit,
        offset: offset,
        categoryId: categoryId,
      );
      return Response.json(body: {'message': 'Success', 'data': result});
    case HttpMethod.post:
      final formData = await request.formData();
      final name = formData.fields['name'];
      final description = formData.fields['description'];
      final price = formData.fields['price'];
      final rating = formData.fields['rating'];
      final categoryId = formData.fields['categoryId'];
      final image = formData.files['image'];
      final mimeType = lookupMimeType(image?.name ?? '');
      if (name == null ||
          description == null ||
          price == null ||
          rating == null ||
          categoryId == null ||
          image == null ||
          mimeType == null) {
        return Response.json(
          statusCode: 400,
          body: {'message': 'Missing required fields'},
        );
      }
      try {
        final product = ProductModel(
          name: name,
          description: description,
          price: double.tryParse(price) ?? 0,
          rating: double.tryParse(rating) ?? 0,
          categoryId: categoryId,
        );

        await productRepo.create(product, mimeType, image);
        return Response.json(body: {'message': 'Product created successfully'});
      } catch (e) {
        return Response.json(
          statusCode: 500,
          body: {'message': 'Error creating product \n $e'},
        );
      }

    case HttpMethod.put:
    case HttpMethod.patch:
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
      return Response.json(
        statusCode: 405,
      );
  }
}
