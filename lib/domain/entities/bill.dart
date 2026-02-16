import 'package:equatable/equatable.dart';

class BillItem extends Equatable {
  final String id;
  final String flowerId;
  final String flowerName;
  final DateTime date;
  final double rate;
  final double quantity;
  final double totalAmount;
  final double totalCommission;
  final double netAmount;

  const BillItem({
    required this.id,
    required this.flowerId,
    required this.flowerName,
    required this.date,
    required this.rate,
    required this.quantity,
    required this.totalAmount,
    required this.totalCommission,
    required this.netAmount,
  });

  @override
  List<Object> get props => [
        id,
        flowerId,
        flowerName,
        date,
        rate,
        quantity,
        totalAmount,
        totalCommission,
        netAmount,
      ];
}

class Bill extends Equatable {
  final String id;
  final String billNumber;
  final String customerId;
  final String customerName;
  final int billYear;
  final int billMonth;
  final double totalQuantity;
  final double totalAmount;
  final double totalCommission;
  final double totalAdvance;
  final double totalExpense;
  final double netAmount;
  final String status;
  final DateTime generatedAt;
  final List<BillItem> items;

  const Bill({
    required this.id,
    required this.billNumber,
    required this.customerId,
    required this.customerName,
    required this.billYear,
    required this.billMonth,
    required this.totalQuantity,
    required this.totalAmount,
    required this.totalCommission,
    required this.totalAdvance,
    required this.totalExpense,
    required this.netAmount,
    required this.status,
    required this.generatedAt,
    required this.items,
  });

  @override
  List<Object> get props => [
        id,
        billNumber,
        customerId,
        customerName,
        billYear,
        billMonth,
        totalQuantity,
        totalAmount,
        totalCommission,
        totalAdvance,
        totalExpense,
        netAmount,
        status,
        generatedAt,
        items,
      ];
}
