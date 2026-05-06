import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:delivery_app/model/user.dart';
import 'package:delivery_app/src/dataBase/database_client.dart';
import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final req = context.request;
  final body = await req.json() as Map<String, dynamic>;
  final refreshToken = body['refreshToken'] as String?;

  if (refreshToken == null) {
    return Response.json(
      statusCode: 400,
      body: {'message': 'Missing refresh token'},
    );
  }

  /// search for the refresh token in the database
  final db = context.read<DataBaseClient>();
  final result = await db.connection.execute(
    Sql.named('SELECT * FROM refresh_tokens WHERE token = @token'),
    parameters: {'token': refreshToken},
  );

  if (result.isEmpty) {
    return Response.json(
      statusCode: 401,
      body: {'message': 'Invalid refresh token'},
    );
  }
  final row = result.first.toColumnMap();

  /// check if the token is expired
  final expiresAt = row['expires_at'] as DateTime;
  if (DateTime.now().isAfter(expiresAt)) {
    return Response.json(
      statusCode: 401,
      body: {'message': 'Refresh token expired'},
    );
  }
  // fetch the user associated with the refresh token
  final userResult = await db.connection.execute(
    Sql.named('SELECT * FROM users WHERE id = @id'),
    parameters: {'id': row['user_id']},
  );

  final user = User.fromMap(userResult.first.toColumnMap());

  /// generate a new access token
  final env = DotEnv()..load();
  final secretKey = env['JWT_SECRET_KEY'] ?? '';
  final newAccessToken = JWT(
    {
      'id': user.id,
      'email': user.email,
      'name': user.name,
    },
  ).sign(
    SecretKey(secretKey),
    expiresIn: const Duration(seconds: 15),
  );

  return Response.json(body: {'accessToken': newAccessToken});
}
