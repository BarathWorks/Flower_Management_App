import '../../core/error/exceptions.dart';
import '../models/dashboard_model.dart';
import 'neon_database.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getDashboardSummary();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final NeonDatabase database;

  DashboardRemoteDataSourceImpl({required this.database});

  @override
  Future<DashboardSummaryModel> getDashboardSummary() async {
    try {
      final result = await database.connection.execute(
        'SELECT * FROM dashboard_summary',
      );

      if (result.isEmpty) {
        throw DatabaseException('Failed to get dashboard summary');
      }

      final row = result.first;
      return DashboardSummaryModel(
        weeklySales: (row[0] as num).toDouble(),
        monthlyProfit: (row[1] as num).toDouble(),
        totalCustomers: row[2] as int,
        totalFlowers: row[3] as int,
        pendingPayments: (row[4] as num).toDouble(),
        todayTransactions: row[5] as int,
      );
    } catch (e) {
      throw DatabaseException('Failed to get dashboard summary: $e');
    }
  }
}
