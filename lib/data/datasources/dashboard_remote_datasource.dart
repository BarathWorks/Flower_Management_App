import '../../core/error/exceptions.dart';
import '../../core/utils/type_converters.dart';
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
        weeklySales: TypeConverters.toDouble(row[0]),
        monthlyProfit: TypeConverters.toDouble(row[1]),
        totalCustomers: TypeConverters.toInt(row[2]),
        totalFlowers: TypeConverters.toInt(row[3]),
        pendingPayments: TypeConverters.toDouble(row[4]),
        todayTransactions: TypeConverters.toInt(row[5]),
      );
    } catch (e) {
      throw DatabaseException('Failed to get dashboard summary: $e');
    }
  }
}
