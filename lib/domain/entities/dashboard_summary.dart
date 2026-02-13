import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final double weeklySales;
  final double monthlyProfit;
  final int totalCustomers;
  final int totalFlowers;
  final double pendingPayments;
  final int todayTransactions;

  const DashboardSummary({
    required this.weeklySales,
    required this.monthlyProfit,
    required this.totalCustomers,
    required this.totalFlowers,
    required this.pendingPayments,
    required this.todayTransactions,
  });

  @override
  List<Object> get props => [
        weeklySales,
        monthlyProfit,
        totalCustomers,
        totalFlowers,
        pendingPayments,
        todayTransactions,
      ];
}
