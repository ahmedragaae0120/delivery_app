import 'package:dart_frog/dart_frog.dart';
import 'package:delivery_app/src/auth/domain/auth_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final req = context.request;
  final body = await req.json() as Map<String, dynamic>;
  final email = body['email'] as String?;
  final password = body['password'] as String?;

  if (email == null || password == null) {
    return Response.json(
      statusCode: 400,
      body: {'message': 'Missing required fields'},
    );
  }
  final authRepository = context.read<AuthRepository>();

  try {
    final result = await authRepository.login(email, password);
    if (result == null) {
      return Response.json(
        statusCode: 401,
        body: {'message': 'Invalid credentials'},
      );
    }
    return Response.json(
      body: {
        'message': 'success',
        'data': result,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'message': 'An error occurred while logging in'},
    );
  }
}
