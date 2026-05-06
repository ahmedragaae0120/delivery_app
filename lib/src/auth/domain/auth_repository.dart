/// A repository that handles authentication-related operation
abstract interface class AuthRepository {
  /// Registers a new user with the provided email and password.
  Future<void> register({
    required String email,
    required String password,
    required String name,
  });

  /// Logs in a user with the provided email and password.
  Future<Map<String, dynamic>?> login(String email, String password);
}
