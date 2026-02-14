import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/daily_flower_entry.dart';
import '../../repositories/transaction_repository.dart';

class GetTodayDailyEntries implements UseCase<List<DailyFlowerEntry>, NoParams> {
  final TransactionRepository repository;

  GetTodayDailyEntries(this.repository);

  @override
  Future<Either<Failure, List<DailyFlowerEntry>>> call(NoParams params) async {
    return await repository.getTodayDailyEntries();
  }
}
