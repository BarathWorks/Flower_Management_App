import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object> get props => [];
}

class LoadAllBills extends BillEvent {}

class GenerateBillEvent extends BillEvent {
  final String customerId;
  final DateTime startDate;
  final DateTime endDate;

  const GenerateBillEvent({
    required this.customerId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [customerId, startDate, endDate];
}

class LoadLastBillDate extends BillEvent {
  final String customerId;

  const LoadLastBillDate(this.customerId);

  @override
  List<Object> get props => [customerId];
}

class LoadBillDetails extends BillEvent {
  final String billId;

  const LoadBillDetails(this.billId);

  @override
  List<Object> get props => [billId];
}

class RefreshBills extends BillEvent {}

class DeleteBillEvent extends BillEvent {
  final String billId;

  const DeleteBillEvent(this.billId);

  @override
  List<Object> get props => [billId];
}

class UpdateBillStatusEvent extends BillEvent {
  final String billId;
  final String status;

  const UpdateBillStatusEvent({
    required this.billId,
    required this.status,
  });

  @override
  List<Object> get props => [billId, status];
}

class AddPaymentEvent extends BillEvent {
  final String billId;
  final double amount;
  final DateTime date;
  final String? notes;

  const AddPaymentEvent({
    required this.billId,
    required this.amount,
    required this.date,
    this.notes,
  });

  @override
  List<Object> get props => [billId, amount, date, notes ?? ''];
}
