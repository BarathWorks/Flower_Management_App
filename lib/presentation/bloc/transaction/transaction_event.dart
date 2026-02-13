import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class LoadTodayTransactions extends TransactionEvent {}

class LoadTransactionsByDate extends TransactionEvent {
  final DateTime date;

  const LoadTransactionsByDate(this.date);

  @override
  List<Object> get props => [date];
}

class AddTransactionEvent extends TransactionEvent {
  final String flowerId;
  final String customerId;
  final DateTime entryDate;
  final double quantity;
  final double rate;
  final double commission;

  const AddTransactionEvent({
    required this.flowerId,
    required this.customerId,
    required this.entryDate,
    required this.quantity,
    required this.rate,
    required this.commission,
  });

  @override
  List<Object> get props =>
      [flowerId, customerId, entryDate, quantity, rate, commission];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

class RefreshTransactions extends TransactionEvent {}
