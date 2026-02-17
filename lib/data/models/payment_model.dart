import '../../core/utils/type_converters.dart';
import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.billId,
    required super.amount,
    required super.date,
    super.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      billId: json['bill_id'] as String,
      amount: TypeConverters.toDouble(json['amount']),
      date: DateTime.parse(json['payment_date'] as String),
      notes: json['notes'] as String?,
    );
  }

  factory PaymentModel.fromDatabase(List<dynamic> row) {
    return PaymentModel(
      id: row[0] as String,
      billId: row[1] as String,
      amount: TypeConverters.toDouble(row[2]),
      date: row[3] as DateTime,
      notes: row[4] as String?,
    );
  }
}
