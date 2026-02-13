import 'package:postgres/postgres.dart';
import 'package:logger/logger.dart';

class NeonDatabase {
  static NeonDatabase? _instance;
  static Connection? _connection;
  final Logger _logger = Logger();

  // Singleton pattern
  NeonDatabase._();

  static NeonDatabase get instance {
    _instance ??= NeonDatabase._();
    return _instance!;
  }

  // Initialize database connection
  Future<void> initialize({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  }) async {
    if (_connection != null) {
      _logger.i('Database connection already established');
      return;
    }

    try {
      _connection = await Connection.open(
        Endpoint(
          host: host,
          port: port,
          database: database,
          username: username,
          password: password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
        ),
      );
      _logger.i('Database connection established successfully');
    } catch (e) {
      _logger.e('Failed to connect to database: $e');
      rethrow;
    }
  }

  Connection get connection {
    if (_connection == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _connection!;
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
    _logger.i('Database connection closed');
  }
}
