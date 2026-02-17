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
        '''
        SELECT
          (SELECT COALESCE(SUM(dfc.amount), 0) 
           FROM daily_flower_customer dfc 
           JOIN daily_flower_entry dfe ON dfc.daily_entry_id = dfe.id 
           WHERE dfe.entry_date >= (CURRENT_DATE - INTERVAL '7 days')) as weekly_sales,
           
          (SELECT COALESCE(SUM(dfc.commission), 0) 
           FROM daily_flower_customer dfc 
           JOIN daily_flower_entry dfe ON dfc.daily_entry_id = dfe.id 
           WHERE DATE_TRUNC('month', dfe.entry_date) = DATE_TRUNC('month', CURRENT_DATE)) as monthly_profit,
           
          (SELECT COUNT(*) FROM customers) as total_customers,
          
          (SELECT COUNT(*) FROM flowers) as total_flowers,
          
          (SELECT COALESCE(SUM(net_amount - COALESCE(paid_amount, 0)), 0) FROM bills WHERE net_amount > COALESCE(paid_amount, 0)) as pending_payments,
          
          (SELECT COUNT(*) 
           FROM daily_flower_customer dfc 
           JOIN daily_flower_entry dfe ON dfc.daily_entry_id = dfe.id 
           WHERE dfe.entry_date = CURRENT_DATE) as today_transactions
        ''',
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
