import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/daily_flower_entry.dart';
import '../../../domain/entities/customer_transaction_detail.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;

  const TransactionLoaded(this.transactions);

  @override
  List<Object> get props => [transactions];
}

class DailyEntriesLoaded extends TransactionState {
  final List<DailyFlowerEntry> entries;

  const DailyEntriesLoaded(this.entries);

  @override
  List<Object> get props => [entries];
}

class CustomerDetailsLoaded extends TransactionState {
  final List<CustomerTransactionDetail> details;
  final String dailyEntryId;

  const CustomerDetailsLoaded(this.details, this.dailyEntryId);

  @override
  List<Object> get props => [details, dailyEntryId];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}

class TransactionOperationSuccess extends TransactionState {
  final String message;

  const TransactionOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
