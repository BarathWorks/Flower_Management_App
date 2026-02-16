import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/customer_repository.dart';

class AddCustomerParams {
  final String name;
  final String? phone;
  final String? address;
  final double? defaultCommission;
  final List<String> flowerIds;

  AddCustomerParams({
    required this.name,
    this.phone,
    this.address,
    this.defaultCommission,
    this.flowerIds = const [],
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
      defaultCommission: params.defaultCommission,
      flowerIds: params.flowerIds,
    );
  }
}
