import '../../core/utils/type_converters.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.weeklySales,
    required super.monthlyProfit,
    required super.totalCustomers,
    required super.totalFlowers,
    required super.pendingPayments,
    required super.todayTransactions,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      weeklySales: TypeConverters.toDouble(json['weekly_sales']),
      monthlyProfit: TypeConverters.toDouble(json['monthly_profit']),
      totalCustomers: TypeConverters.toInt(json['total_customers']),
      totalFlowers: TypeConverters.toInt(json['total_flowers']),
      pendingPayments: TypeConverters.toDouble(json['pending_payments']),
      todayTransactions: TypeConverters.toInt(json['today_transactions']),
    );
  }
}
