import 'package:equatable/equatable.dart';
import '../../../domain/usecases/transaction/add_transaction.dart';

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

class LoadTodayDailyEntries extends TransactionEvent {}

class LoadDailyEntriesByDate extends TransactionEvent {
  final DateTime date;

  const LoadDailyEntriesByDate(this.date);

  @override
  List<Object> get props => [date];
}

class LoadCustomerDetailsForEntry extends TransactionEvent {
  final String dailyEntryId;

  const LoadCustomerDetailsForEntry(this.dailyEntryId);

  @override
  List<Object> get props => [dailyEntryId];
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

class AddMultipleCustomerTransactionEvent extends TransactionEvent {
  final String flowerId;
  final DateTime entryDate;
  final List<CustomerTransactionData> customers;

  const AddMultipleCustomerTransactionEvent({
    required this.flowerId,
    required this.entryDate,
    required this.customers,
  });

  @override
  List<Object> get props => [flowerId, entryDate, customers];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

class RefreshTransactions extends TransactionEvent {}
