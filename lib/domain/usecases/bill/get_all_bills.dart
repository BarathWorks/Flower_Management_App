import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/bill.dart';
import '../../repositories/bill_repository.dart';

class GetAllBills implements UseCase<List<Bill>, NoParams> {
  final BillRepository repository;

  GetAllBills(this.repository);

  @override
  Future<Either<Failure, List<Bill>>> call(NoParams params) async {
    return await repository.getAllBills();
  }
}
