import '../../domain/entities/bill.dart';

class BillItemModel extends BillItem {
  const BillItemModel({
    required super.id,
    required super.flowerId,
    required super.flowerName,
    required super.totalQuantity,
    required super.totalAmount,
    required super.totalCommission,
    required super.netAmount,
  });

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      id: json['id'] as String,
      flowerId: json['flower_id'] as String,
      flowerName: json['flower_name'] as String,
      totalQuantity: (json['total_quantity'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalCommission: (json['total_commission'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
    );
  }
}

class BillModel extends Bill {
  const BillModel({
    required super.id,
    required super.billNumber,
    required super.customerId,
    required super.customerName,
    required super.billYear,
    required super.billMonth,
    required super.totalQuantity,
    required super.totalAmount,
    required super.totalCommission,
    required super.totalExpense,
    required super.netAmount,
    required super.status,
    required super.generatedAt,
    required super.items,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>?;
    final items = itemsList
            ?.map(
                (item) => BillItemModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return BillModel(
      id: json['id'] as String,
      billNumber: json['bill_number'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      billYear: json['bill_year'] as int,
      billMonth: json['bill_month'] as int,
      totalQuantity: (json['total_quantity'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalCommission: (json['total_commission'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      netAmount: (json['net_amount'] as num).toDouble(),
      status: json['status'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      items: items,
    );
  }
}
