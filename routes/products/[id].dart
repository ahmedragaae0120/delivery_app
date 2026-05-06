import 'package:dart_frog/dart_frog.dart';
import 'package:delivery_app/model/product_model.dart';
import 'package:delivery_app/src/products/domain/product_repository.dart';
import 'package:mime/mime.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final req = context.request;
  final method = req.method;
  final productRepo = context.read<ProductsRepository>();
  final product = await productRepo.getById(id);
  if (id.isEmpty || product == null) {
    return Response.json(
      statusCode: 404,
      body: {'message': 'Product not found'},
    );
  }

  switch (method) {
    case HttpMethod.get:
      final result = await productRepo.getById(id);
      return Response.json(body: {'message': 'Success', 'data': result});
    case HttpMethod.delete:
      await productRepo.delete(id);
      return Response.json(body: {'message': 'Product deleted successfully'});
    case HttpMethod.put:
      final formData = await req.formData();
      final name = formData.fields['name'];
      final description = formData.fields['description'];
      final price = formData.fields['price'];
      final rating = formData.fields['rating'];
      final categoryId = formData.fields['categoryId'];
      final image = formData.files['image'];
      final mimeType = lookupMimeType(image?.name ?? '');
      final updatedProduct = ProductModel(
        id: id,
        name: name ?? product.name,
        description: description ?? product.description,
        imageUrl: product.imageUrl,
        price:
            double.tryParse(price ?? product.price.toString()) ?? product.price,
        rating: double.tryParse(rating ?? product.rating.toString()) ??
            product.rating,
        categoryId: categoryId ?? product.categoryId,
      );
      await productRepo.update(
        id,
        updatedProduct,
        mimeType ?? '',
        image,
      );
      return Response.json(body: {'message': 'Product updated successfully'});
    case HttpMethod.post:
    case HttpMethod.patch:
    case HttpMethod.head:
    case HttpMethod.options:
      return Response.json(statusCode: 405);
  }
}
