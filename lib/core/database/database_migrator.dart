import 'package:logger/logger.dart';
import '../../data/datasources/neon_database.dart';

class DatabaseMigrator {
  final NeonDatabase database;
  final Logger _logger = Logger();

  DatabaseMigrator(this.database);

  Future<void> migrate() async {
    try {
      _logger.i('Starting database migration...');

      // Add default_rate to flowers table
      await database.connection.execute(
        'ALTER TABLE flowers ADD COLUMN IF NOT EXISTS default_rate DOUBLE PRECISION',
      );
      _logger.i('Added default_rate to flowers table');

      // Add default_commission to customers table
      await database.connection.execute(
        'ALTER TABLE customers ADD COLUMN IF NOT EXISTS default_commission DOUBLE PRECISION',
      );
      _logger.i('Added default_commission to customers table');

      // Create settings table
      await database.connection.execute(
        'CREATE TABLE IF NOT EXISTS settings (key VARCHAR(50) PRIMARY KEY, value TEXT)',
      );
      _logger.i('Created settings table');

      _logger.i('Database migration completed successfully');
    } catch (e) {
      _logger.e('Database migration failed: $e');
      // We don't rethrow here to allow the app to try running even if migration fails
      // (e.g. if columns already exist but error text is different)
    }
  }
}
