import 'package:postgres/postgres.dart';

///database client
class DataBaseClient {
  /// DataBaseClient._internal
  factory DataBaseClient() => _instance;

  DataBaseClient._internal() {
    _pool = Pool.withEndpoints(
      [
        Endpoint(
          host: 'localhost',
          database: 'Food_Delivery',
          username: 'postgres',
          password: '01208100776',
        ),
      ],
      settings: const PoolSettings(
        sslMode: SslMode.disable,
        maxConnectionCount: 10,
      ),
    );
  }

  static final DataBaseClient _instance = DataBaseClient._internal();

  late final Pool<Connection> _pool;

  ///get connection pool
  Pool<Connection> get connection => _pool;

  ///close connection
  Future<void> close() async => _pool.close();
}
