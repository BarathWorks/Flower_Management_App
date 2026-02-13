import '../../core/error/exceptions.dart';
import '../models/flower_model.dart';
import 'neon_database.dart';

abstract class FlowerRemoteDataSource {
  Future<List<FlowerModel>> getAllFlowers();
  Future<void> addFlower(String name);
  Future<void> deleteFlower(String id);
}

class FlowerRemoteDataSourceImpl implements FlowerRemoteDataSource {
  final NeonDatabase database;

  FlowerRemoteDataSourceImpl({required this.database});

  @override
  Future<List<FlowerModel>> getAllFlowers() async {
    try {
      final result = await database.connection.execute(
        'SELECT * FROM flowers ORDER BY name ASC',
      );

      return result.map((row) {
        return FlowerModel(
          id: row[0] as String,
          name: row[1] as String,
          createdAt: row[2] as DateTime,
        );
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get flowers: $e');
    }
  }

  @override
  Future<void> addFlower(String name) async {
    try {
      await database.connection.execute(
        'INSERT INTO flowers (name) VALUES (@name)',
        parameters: {'name': name},
      );
    } catch (e) {
      throw DatabaseException('Failed to add flower: $e');
    }
  }

  @override
  Future<void> deleteFlower(String id) async {
    try {
      await database.connection.execute(
        'DELETE FROM flowers WHERE id = @id',
        parameters: {'id': id},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete flower: $e');
    }
  }
}
