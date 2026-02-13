import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String dailyEntryId;
  final String customerId;
  final String customerName;
  final String flowerId;
  final String flowerName;
  final DateTime entryDate;
  final double quantity;
  final double rate;
  final double amount;
  final double commission;
  final double netAmount;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.dailyEntryId,
    required this.customerId,
    required this.customerName,
    required this.flowerId,
    required this.flowerName,
    required this.entryDate,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.commission,
    required this.netAmount,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        dailyEntryId,
        customerId,
        customerName,
        flowerId,
        flowerName,
        entryDate,
        quantity,
        rate,
        amount,
        commission,
        netAmount,
        createdAt,
      ];
}
