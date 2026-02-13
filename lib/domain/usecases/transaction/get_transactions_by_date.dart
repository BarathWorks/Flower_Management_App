import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

class GetTransactionsByDate implements UseCase<List<Transaction>, DateTime> {
  final TransactionRepository repository;

  GetTransactionsByDate(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(DateTime params) async {
    return await repository.getTransactionsByDate(params);
  }
}
