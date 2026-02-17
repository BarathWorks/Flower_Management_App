import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String billId;
  final double amount;
  final DateTime date;
  final String? notes;

  const Payment({
    required this.id,
    required this.billId,
    required this.amount,
    required this.date,
    this.notes,
  });

  @override
  List<Object?> get props => [id, billId, amount, date, notes];
}
