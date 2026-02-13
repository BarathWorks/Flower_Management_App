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
      weeklySales: (json['weekly_sales'] as num).toDouble(),
      monthlyProfit: (json['monthly_profit'] as num).toDouble(),
      totalCustomers: json['total_customers'] as int,
      totalFlowers: json['total_flowers'] as int,
      pendingPayments: (json['pending_payments'] as num).toDouble(),
      todayTransactions: json['today_transactions'] as int,
    );
  }
}
