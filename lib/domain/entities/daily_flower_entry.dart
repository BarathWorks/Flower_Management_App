import 'package:equatable/equatable.dart';

class DailyFlowerEntry extends Equatable {
  final String id;
  final DateTime entryDate;
  final String flowerId;
  final String flowerName;
  final double totalQuantity;
  final double totalAmount;
  final double totalCommission;
  final double netAmount;
  final int customerCount;
  final DateTime createdAt;

  const DailyFlowerEntry({
    required this.id,
    required this.entryDate,
    required this.flowerId,
    required this.flowerName,
    required this.totalQuantity,
    required this.totalAmount,
    required this.totalCommission,
    required this.netAmount,
    required this.customerCount,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        entryDate,
        flowerId,
        flowerName,
        totalQuantity,
        totalAmount,
        totalCommission,
        netAmount,
        customerCount,
        createdAt,
      ];
}
