import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:delivery_app/model/user.dart';
import 'package:delivery_app/src/auth/domain/auth_repository.dart';
import 'package:delivery_app/src/dataBase/database_client.dart';
import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';
import 'package:uuid/uuid.dart';

/// AuthRepositoryImpl
class AuthRepositoryImpl implements AuthRepository {
  /// AuthRepositoryImpl
  AuthRepositoryImpl(this._db);
  final DataBaseClient _db;

  final _uuid = const Uuid();

  @override
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final result = await _db.connection.execute(
        Sql.named('SELECT * FROM public.users  WHERE email = @email'),
        parameters: {
          'email': email,
        },
      );
      if (result.isEmpty) return null;
      final user = User.fromMap(result.first.toColumnMap());
      final isValid = BCrypt.checkpw(password, user.password);
      if (!isValid) return null;

      final env = DotEnv()..load();
      final secretKey = env['JWT_SECRET_KEY'] ?? '';

      final accessToken = JWT(
        {
          'id': user.id,
          'email': user.email,
          'name': user.name,
        },
      ).sign(
        SecretKey(secretKey),
        expiresIn: const Duration(seconds: 15),
      );

      final refreshToken = _uuid.v4();

      await _db.connection.execute(
        Sql.named(
          '''
        insert into refresh_tokens (id, user_id, token,expires_at) 
        values (@id, @userId, @token, @expires_at);
        ''',
        ),
        parameters: {
          'id': _uuid.v4(),
          'userId': user.id,
          'token': refreshToken,
          'expires_at': DateTime.now().add(const Duration(days: 7)),
        },
      );

      return {
        'token': accessToken,
        'refreshToken': refreshToken,
        'user': {
          'id': user.id,
          'email': user.email,
          'name': user.name,
        },
      };
    } catch (e) {
      return {
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final existingUser = await _db.connection.execute(
      Sql.named('SELECT * FROM public.users WHERE email = @email'),
      parameters: {
        'email': email,
      },
    );

    if (existingUser.isNotEmpty) {
      throw Exception('Email already in use');
    }
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    await _db.connection.execute(
      Sql.named(
        '''
      INSERT INTO public.users (id, email, password, name) VALUES (@id, @email, @password, @name);
      ''',
      ),
      parameters: {
        'id': _uuid.v4(),
        'email': email,
        'password': hashedPassword,
        'name': name,
      },
    );
  }
}
