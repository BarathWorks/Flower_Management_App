import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/customer_repository.dart';

class AddCustomerParams {
  final String name;
  final String? phone;
  final String? address;

  AddCustomerParams({
    required this.name,
    this.phone,
    this.address,
  });
}

class AddCustomer implements UseCase<void, AddCustomerParams> {
  final CustomerRepository repository;

  AddCustomer(this.repository);

  @override
  Future<Either<Failure, void>> call(AddCustomerParams params) async {
    return await repository.addCustomer(
      name: params.name,
      phone: params.phone,
      address: params.address,
    );
  }
}
