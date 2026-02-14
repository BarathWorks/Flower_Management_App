import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';

class GetCustomersWithoutBillsParams {
  final int year;
  final int month;

  GetCustomersWithoutBillsParams({
    required this.year,
    required this.month,
  });
}

class GetCustomersWithoutBills
    implements UseCase<List<Customer>, GetCustomersWithoutBillsParams> {
  final CustomerRepository repository;

  GetCustomersWithoutBills(this.repository);

  @override
  Future<Either<Failure, List<Customer>>> call(
      GetCustomersWithoutBillsParams params) async {
    return await repository.getCustomersWithoutBills(
      year: params.year,
      month: params.month,
    );
  }
}
