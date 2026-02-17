import 'package:equatable/equatable.dart';
import '../../../domain/entities/bill.dart';

abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillListLoaded extends BillState {
  final List<Bill> bills;

  const BillListLoaded(this.bills);

  @override
  List<Object> get props => [bills];
}

class BillDetailsLoaded extends BillState {
  final Bill bill;

  const BillDetailsLoaded(this.bill);

  @override
  List<Object> get props => [bill];
}

class BillError extends BillState {
  final String message;

  const BillError(this.message);

  @override
  List<Object> get props => [message];
}

class BillOperationSuccess extends BillState {
  final String message;

  const BillOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class LastBillDateLoaded extends BillState {
  final DateTime? date;

  const LastBillDateLoaded(this.date);

  @override
  List<Object> get props => [date ?? DateTime(0)];
}
