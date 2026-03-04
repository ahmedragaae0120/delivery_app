import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final request = context.request;
  final method = request.method;
  switch (method) {
    case HttpMethod.get:
      break;
    case HttpMethod.post:
      break;
    case HttpMethod.put:
    case HttpMethod.patch:
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
      return Response.json(
        body: {'message': 'Method not allowed'},
        statusCode: 405,
      );
  }

  return Response.json(body: {'message': 'products'});
}
