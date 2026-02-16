import 'package:equatable/equatable.dart';

class CustomerTransactionDetail extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final double quantity;
  final double rate;
  final double amount;
  final double commission;
  final double advance;
  final double netAmount;
  final DateTime createdAt;

  const CustomerTransactionDetail({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.commission,
    required this.advance,
    required this.netAmount,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        customerId,
        customerName,
        quantity,
        rate,
        amount,
        commission,
        advance,
        netAmount,
        createdAt,
      ];
}
