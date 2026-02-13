import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../datasources/bill_remote_datasource.dart';

class BillRepositoryImpl implements BillRepository {
  final BillRemoteDataSource remoteDataSource;

  BillRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> generateMonthlyBill({
    required String customerId,
    required int year,
    required int month,
  }) async {
    try {
      final billId = await remoteDataSource.generateMonthlyBill(
        customerId: customerId,
        year: year,
        month: month,
      );
      return Right(billId);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Bill>> getBillDetails(String billId) async {
    try {
      final bill = await remoteDataSource.getBillDetails(billId);
      return Right(bill);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Bill>>> getAllBills() async {
    try {
      final bills = await remoteDataSource.getAllBills();
      return Right(bills);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Bill>>> getCustomerBills(
      String customerId) async {
    try {
      final bills = await remoteDataSource.getCustomerBills(customerId);
      return Right(bills);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
