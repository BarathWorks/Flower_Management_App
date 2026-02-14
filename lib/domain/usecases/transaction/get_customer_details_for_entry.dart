import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/customer_transaction_detail.dart';
import '../../repositories/transaction_repository.dart';

class GetCustomerDetailsForEntry implements UseCase<List<CustomerTransactionDetail>, String> {
  final TransactionRepository repository;

  GetCustomerDetailsForEntry(this.repository);

  @override
  Future<Either<Failure, List<CustomerTransactionDetail>>> call(String dailyEntryId) async {
    return await repository.getCustomerDetailsForEntry(dailyEntryId);
  }
}
