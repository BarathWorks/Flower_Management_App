import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../repositories/bill_repository.dart';

class AddPayment implements UseCase<void, AddPaymentParams> {
  final BillRepository repository;

  AddPayment(this.repository);

  @override
  Future<Either<Failure, void>> call(AddPaymentParams params) async {
    return await repository.addPayment(
      billId: params.billId,
      amount: params.amount,
      date: params.date,
      notes: params.notes,
    );
  }
}

class AddPaymentParams extends Equatable {
  final String billId;
  final double amount;
  final DateTime date;
  final String? notes;

  const AddPaymentParams({
    required this.billId,
    required this.amount,
    required this.date,
    this.notes,
  });

  @override
  List<Object?> get props => [billId, amount, date, notes];
}
