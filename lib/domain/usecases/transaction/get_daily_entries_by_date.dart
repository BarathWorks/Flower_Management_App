import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/daily_flower_entry.dart';
import '../../repositories/transaction_repository.dart';

class GetDailyEntriesByDate implements UseCase<List<DailyFlowerEntry>, DateTime> {
  final TransactionRepository repository;

  GetDailyEntriesByDate(this.repository);

  @override
  Future<Either<Failure, List<DailyFlowerEntry>>> call(DateTime date) async {
    return await repository.getDailyEntriesByDate(date);
  }
}
