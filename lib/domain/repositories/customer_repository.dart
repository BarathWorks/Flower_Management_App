import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getAllCustomers();
  Future<Either<Failure, List<Customer>>> getCustomersWithoutBills({
    required int year,
    required int month,
  });
  Future<Either<Failure, Customer>> getCustomerById(String id);
  Future<Either<Failure, void>> addCustomer({
    required String name,
    String? phone,
    String? address,
    double? defaultCommission,
  });
  Future<Either<Failure, void>> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? address,
    double? defaultCommission,
  });
  Future<Either<Failure, void>> deleteCustomer(String id);
}
