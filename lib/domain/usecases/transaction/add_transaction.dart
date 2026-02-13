import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/transaction_repository.dart';

class AddTransactionParams {
  final String flowerId;
  final String customerId;
  final DateTime entryDate;
  final double quantity;
  final double rate;
  final double commission;

  AddTransactionParams({
    required this.flowerId,
    required this.customerId,
    required this.entryDate,
    required this.quantity,
    required this.rate,
    required this.commission,
  });
}

class AddTransaction implements UseCase<void, AddTransactionParams> {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) async {
    return await repository.addTransaction(
      flowerId: params.flowerId,
      customerId: params.customerId,
      entryDate: params.entryDate,
      quantity: params.quantity,
      rate: params.rate,
      commission: params.commission,
    );
  }
}
