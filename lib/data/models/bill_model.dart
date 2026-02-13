import '../../core/utils/type_converters.dart';
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
      totalQuantity: TypeConverters.toDouble(json['total_quantity']),
      totalAmount: TypeConverters.toDouble(json['total_amount']),
      totalCommission: TypeConverters.toDouble(json['total_commission']),
      netAmount: TypeConverters.toDouble(json['net_amount']),
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
      totalQuantity: TypeConverters.toDouble(json['total_quantity']),
      totalAmount: TypeConverters.toDouble(json['total_amount']),
      totalCommission: TypeConverters.toDouble(json['total_commission']),
      totalExpense: TypeConverters.toDouble(json['total_expense']),
      netAmount: TypeConverters.toDouble(json['net_amount']),
      status: json['status'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      items: items,
    );
  }
}
