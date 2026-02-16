import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/transaction_repository.dart';

class CustomerTransactionData {
  final String customerId;
  final double quantity;
  final double rate;
  final double commission;
  final double advance;

  CustomerTransactionData({
    required this.customerId,
    required this.quantity,
    required this.rate,
    required this.commission,
    this.advance = 0,
  });
}

class AddTransactionParams {
  final String flowerId;
  final DateTime entryDate;
  final List<CustomerTransactionData> customers;

  AddTransactionParams({
    required this.flowerId,
    required this.entryDate,
    required this.customers,
  });
}

class AddTransaction implements UseCase<void, AddTransactionParams> {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(AddTransactionParams params) async {
    return await repository.addMultipleCustomerTransactions(
      flowerId: params.flowerId,
      entryDate: params.entryDate,
      customers: params.customers,
    );
  }
}
