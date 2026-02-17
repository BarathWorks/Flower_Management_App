import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/bill_repository.dart';

class GetLastBillDate {
  final BillRepository repository;

  GetLastBillDate(this.repository);

  Future<Either<Failure, DateTime?>> call(String customerId) async {
    return await repository.getLastBillDate(customerId);
  }
}
