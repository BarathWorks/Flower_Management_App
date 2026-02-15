import '../../core/error/exceptions.dart';
import 'neon_database.dart';

abstract class SettingsRemoteDataSource {
  Future<double?> getGlobalCommission();
  Future<void> setGlobalCommission(double commission);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final NeonDatabase database;

  SettingsRemoteDataSourceImpl({required this.database});

  @override
  Future<double?> getGlobalCommission() async {
    try {
      final result = await database.connection.execute(
        "SELECT value FROM settings WHERE key = 'global_commission'",
      );

      if (result.isEmpty) {
        return null;
      }

      return double.tryParse(result.first[0] as String);
    } catch (e) {
      throw DatabaseException('Failed to get global commission: $e');
    }
  }

  @override
  Future<void> setGlobalCommission(double commission) async {
    try {
      await database.connection.execute(
        "INSERT INTO settings (key, value) VALUES ('global_commission', \$1) ON CONFLICT (key) DO UPDATE SET value = \$1",
        parameters: [commission.toString()],
      );
    } catch (e) {
      throw DatabaseException('Failed to set global commission: $e');
    }
  }
}
