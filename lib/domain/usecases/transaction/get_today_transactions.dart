import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

class GetTodayTransactions implements UseCase<List<Transaction>, NoParams> {
  final TransactionRepository repository;

  GetTodayTransactions(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) async {
    return await repository.getTodayTransactions();
  }
}
