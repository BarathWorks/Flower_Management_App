import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/bill_repository.dart';

class UpdateBillStatus implements UseCase<void, UpdateBillStatusParams> {
  final BillRepository repository;

  UpdateBillStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateBillStatusParams params) async {
    return await repository.updateBillStatus(params.billId, params.status);
  }
}

class UpdateBillStatusParams {
  final String billId;
  final String status;

  UpdateBillStatusParams({required this.billId, required this.status});
}
