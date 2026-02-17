import 'package:equatable/equatable.dart';
import 'payment.dart';

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
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalQuantity;
  final double totalAmount;
  final double totalCommission;
  final double totalAdvance;
  final double totalExpense;
  final double netAmount;
  final double paidAmount;
  final DateTime generatedAt;
  final List<BillItem> items;
  final List<Payment> payments;
  final String _status; // Internal status from DB

  const Bill({
    required this.id,
    required this.billNumber,
    required this.customerId,
    required this.customerName,
    required this.billYear,
    required this.billMonth,
    this.startDate,
    this.endDate,
    required this.totalQuantity,
    required this.totalAmount,
    required this.totalCommission,
    required this.totalAdvance,
    required this.totalExpense,
    required this.netAmount,
    this.paidAmount = 0,
    required String status,
    required this.generatedAt,
    this.items = const [],
    this.payments = const [],
  }) : _status = status;

  String get status {
    if (_status == 'PAID') return 'PAID';
    if (paidAmount >= netAmount && netAmount > 0) return 'PAID';
    if (paidAmount > 0 && paidAmount < netAmount) return 'PARTIAL';
    return 'UNPAID';
  }

  @override
  List<Object?> get props => [
        id,
        billNumber,
        customerId,
        customerName,
        billYear,
        billMonth,
        startDate,
        endDate,
        totalQuantity,
        totalAmount,
        totalCommission,
        totalAdvance,
        totalExpense,
        netAmount,
        paidAmount,
        _status,
        generatedAt,
        items,
        payments,
      ];
}
