import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/bill_repository.dart';

class GenerateMonthlyBillParams {
  final String customerId;
  final int year;
  final int month;

  GenerateMonthlyBillParams({
    required this.customerId,
    required this.year,
    required this.month,
  });
}

class GenerateMonthlyBill
    implements UseCase<String, GenerateMonthlyBillParams> {
  final BillRepository repository;

  GenerateMonthlyBill(this.repository);

  @override
  Future<Either<Failure, String>> call(GenerateMonthlyBillParams params) async {
    return await repository.generateMonthlyBill(
      customerId: params.customerId,
      year: params.year,
      month: params.month,
    );
  }
}
