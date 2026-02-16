import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;

  CustomerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Customer>>> getAllCustomers() async {
    try {
      final customers = await remoteDataSource.getAllCustomers();
      return Right(customers);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> getCustomersWithoutBills({
    required int year,
    required int month,
  }) async {
    try {
      final customers = await remoteDataSource.getCustomersWithoutBills(
        year: year,
        month: month,
      );
      return Right(customers);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(String id) async {
    try {
      final customer = await remoteDataSource.getCustomerById(id);
      return Right(customer);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addCustomer({
    required String name,
    String? phone,
    String? address,
    double? defaultCommission,
    List<String> flowerIds = const [],
  }) async {
    try {
      await remoteDataSource.addCustomer(
        name: name,
        phone: phone,
        address: address,
        defaultCommission: defaultCommission,
        flowerIds: flowerIds,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? address,
    double? defaultCommission,
    List<String> flowerIds = const [],
  }) async {
    try {
      await remoteDataSource.updateCustomer(
        id: id,
        name: name,
        phone: phone,
        address: address,
        defaultCommission: defaultCommission,
        flowerIds: flowerIds,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String id) async {
    try {
      await remoteDataSource.deleteCustomer(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
