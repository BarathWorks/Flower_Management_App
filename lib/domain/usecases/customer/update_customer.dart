import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/customer_repository.dart';

class UpdateCustomerParams {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final double? defaultCommission;

  UpdateCustomerParams({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.defaultCommission,
  });
}

class UpdateCustomer implements UseCase<void, UpdateCustomerParams> {
  final CustomerRepository repository;

  UpdateCustomer(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCustomerParams params) async {
    return await repository.updateCustomer(
      id: params.id,
      name: params.name,
      phone: params.phone,
      address: params.address,
      defaultCommission: params.defaultCommission,
    );
  }
}
