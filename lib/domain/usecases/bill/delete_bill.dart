import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/bill_repository.dart';

class DeleteBill implements UseCase<void, String> {
  final BillRepository repository;

  DeleteBill(this.repository);

  @override
  Future<Either<Failure, void>> call(String billId) async {
    return await repository.deleteBill(billId);
  }
}
