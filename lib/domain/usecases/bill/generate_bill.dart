import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/bill_repository.dart';

class GenerateBillParams {
  final String customerId;
  final DateTime startDate;
  final DateTime endDate;

  GenerateBillParams({
    required this.customerId,
    required this.startDate,
    required this.endDate,
  });
}

class GenerateBill {
  final BillRepository repository;

  GenerateBill(this.repository);

  Future<Either<Failure, String>> call(GenerateBillParams params) async {
    return await repository.generateBill(
      customerId: params.customerId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}
