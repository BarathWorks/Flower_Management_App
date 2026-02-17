import '../../core/utils/type_converters.dart';
import '../../domain/entities/bill.dart';
import 'payment_model.dart';

class BillItemModel extends BillItem {
  const BillItemModel({
    required super.id,
    required super.flowerId,
    required super.flowerName,
    required super.date,
    required super.rate,
    required super.quantity,
    required super.totalAmount,
    required super.totalCommission,
    required super.netAmount,
  });

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      id: json['id'] as String,
      flowerId: json['flower_id'] as String,
      flowerName: json['flower_name'] as String,
      date: DateTime.parse(json['transaction_date'] as String),
      rate: TypeConverters.toDouble(json['rate']),
      quantity: TypeConverters.toDouble(json['quantity']),
      totalAmount: TypeConverters.toDouble(json['total_amount']),
      totalCommission: TypeConverters.toDouble(json['commission']),
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
    super.startDate,
    super.endDate,
    required super.totalQuantity,
    required super.totalAmount,
    required super.totalCommission,
    required super.totalAdvance,
    required super.totalExpense,
    required super.netAmount,
    super.paidAmount,
    required super.status,
    required super.generatedAt,
    super.items,
    super.payments,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>?;
    final items = itemsList
            ?.map(
                (item) => BillItemModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final paymentsList = json['payments'] as List<dynamic>?;
    final payments = paymentsList
            ?.map((payment) =>
                PaymentModel.fromJson(payment as Map<String, dynamic>))
            .toList() ??
        [];

    return BillModel(
      id: json['id'] as String,
      billNumber: json['bill_number'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      billYear: json['bill_year'] as int,
      billMonth: json['bill_month'] as int,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      totalQuantity: TypeConverters.toDouble(json['total_quantity']),
      totalAmount: TypeConverters.toDouble(json['total_amount']),
      totalCommission: TypeConverters.toDouble(json['total_commission']),
      totalAdvance: TypeConverters.toDouble(json['total_advance']),
      totalExpense: TypeConverters.toDouble(json['total_expense']),
      netAmount: TypeConverters.toDouble(json['net_amount']),
      paidAmount: TypeConverters.toDouble(json['paid_amount'] ?? 0),
      status: json['status'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      items: items,
      payments: payments,
    );
  }
}
