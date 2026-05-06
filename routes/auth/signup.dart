import 'package:dart_frog/dart_frog.dart';
import 'package:delivery_app/src/auth/domain/auth_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  final req = context.request;
  final authRepository = context.read<AuthRepository>();

  final body = await req.json() as Map<String, dynamic>;
  final name = body['name'] as String?;
  final email = body['email'] as String?;
  final password = body['password'] as String?;

  if (name == null || email == null || password == null) {
    return Response.json(
      statusCode: 400,
      body: {'message': 'Missing required fields'},
    );
  }
  try {
    await authRepository.register(name: name, email: email, password: password);

    return Response.json(body: {'message': 'User created'});
  } catch (e) {
    return Response.json(
      statusCode: 400,
      body: {'message': e.toString().replaceFirst('Exception: ', '')},
    );
  }
}
