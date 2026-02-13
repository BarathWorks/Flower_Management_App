import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/bill.dart';
import '../../repositories/bill_repository.dart';

class GetBillDetails implements UseCase<Bill, String> {
  final BillRepository repository;

  GetBillDetails(this.repository);

  @override
  Future<Either<Failure, Bill>> call(String params) async {
    return await repository.getBillDetails(params);
  }
}
