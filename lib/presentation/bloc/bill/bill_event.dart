import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object> get props => [];
}

class LoadAllBills extends BillEvent {}

class GenerateBillEvent extends BillEvent {
  final String customerId;
  final int year;
  final int month;

  const GenerateBillEvent({
    required this.customerId,
    required this.year,
    required this.month,
  });

  @override
  List<Object> get props => [customerId, year, month];
}

class LoadBillDetails extends BillEvent {
  final String billId;

  const LoadBillDetails(this.billId);

  @override
  List<Object> get props => [billId];
}

class RefreshBills extends BillEvent {}
