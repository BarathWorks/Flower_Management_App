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
  Future<Either<Failure, String>> generateBill({
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final billId = await remoteDataSource.generateBill(
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(billId);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastBillDate(String customerId) async {
    try {
      final date = await remoteDataSource.getLastBillDate(customerId);
      return Right(date);
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

  @override
  Future<Either<Failure, void>> deleteBill(String billId) async {
    try {
      await remoteDataSource.deleteBill(billId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBillStatus(
      String billId, String status) async {
    try {
      await remoteDataSource.updateBillStatus(billId, status);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addPayment({
    required String billId,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    try {
      await remoteDataSource.addPayment(
        billId: billId,
        amount: amount,
        date: date,
        notes: notes,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
