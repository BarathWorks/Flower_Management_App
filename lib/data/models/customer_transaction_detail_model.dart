import '../../domain/entities/customer_transaction_detail.dart';
import '../../core/utils/type_converters.dart';

class CustomerTransactionDetailModel extends CustomerTransactionDetail {
  const CustomerTransactionDetailModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.quantity,
    required super.rate,
    required super.amount,
    required super.commission,
    required super.netAmount,
    required super.createdAt,
  });

  factory CustomerTransactionDetailModel.fromDatabase(List<dynamic> row) {
    return CustomerTransactionDetailModel(
      id: row[0] as String,
      customerId: row[1] as String,
      customerName: row[2] as String,
      quantity: TypeConverters.toDouble(row[3]),
      rate: TypeConverters.toDouble(row[4]),
      amount: TypeConverters.toDouble(row[5]),
      commission: TypeConverters.toDouble(row[6]),
      netAmount: TypeConverters.toDouble(row[7]),
      createdAt: row[8] as DateTime,
    );
  }
}
