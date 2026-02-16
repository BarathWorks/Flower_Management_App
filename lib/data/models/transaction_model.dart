import '../../core/utils/type_converters.dart';
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.dailyEntryId,
    required super.customerId,
    required super.customerName,
    required super.flowerId,
    required super.flowerName,
    required super.entryDate,
    required super.quantity,
    required super.rate,
    required super.amount,
    required super.commission,
    required super.advance,
    required super.netAmount,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      dailyEntryId: json['daily_entry_id'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      flowerId: json['flower_id'] as String,
      flowerName: json['flower_name'] as String,
      entryDate: DateTime.parse(json['entry_date'] as String),
      quantity: TypeConverters.toDouble(json['quantity']),
      rate: TypeConverters.toDouble(json['rate']),
      amount: TypeConverters.toDouble(json['amount']),
      commission: TypeConverters.toDouble(json['commission']),
      advance: TypeConverters.toDouble(json['advance']),
      netAmount: TypeConverters.toDouble(json['net_amount']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'daily_entry_id': dailyEntryId,
      'customer_id': customerId,
      'customer_name': customerName,
      'flower_id': flowerId,
      'flower_name': flowerName,
      'entry_date': entryDate.toIso8601String(),
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
      'commission': commission,
      'advance': advance,
      'net_amount': netAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
