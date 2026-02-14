import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/daily_flower_entry.dart';
import '../../domain/entities/customer_transaction_detail.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/transaction/add_transaction.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Transaction>>> getTodayTransactions() async {
    try {
      final transactions = await remoteDataSource.getTodayTransactions();
      return Right(transactions);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByDate(
      DateTime date) async {
    try {
      final transactions = await remoteDataSource.getTransactionsByDate(date);
      return Right(transactions);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // For now, just get transactions for the start date
      // In production, you'd query the date range
      final transactions =
          await remoteDataSource.getTransactionsByDate(startDate);
      return Right(transactions);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction({
    required String flowerId,
    required String customerId,
    required DateTime entryDate,
    required double quantity,
    required double rate,
    required double commission,
  }) async {
    try {
      await remoteDataSource.addTransaction(
        flowerId: flowerId,
        customerId: customerId,
        entryDate: entryDate,
        quantity: quantity,
        rate: rate,
        commission: commission,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMultipleCustomerTransactions({
    required String flowerId,
    required DateTime entryDate,
    required List<CustomerTransactionData> customers,
  }) async {
    try {
      await remoteDataSource.addMultipleCustomerTransactions(
        flowerId: flowerId,
        entryDate: entryDate,
        customers: customers,
      );
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) async {
    try {
      await remoteDataSource.deleteTransaction(transactionId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyFlowerEntry>>> getTodayDailyEntries() async {
    try {
      final entries = await remoteDataSource.getTodayDailyEntries();
      return Right(entries);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyFlowerEntry>>> getDailyEntriesByDate(
      DateTime date) async {
    try {
      final entries = await remoteDataSource.getDailyEntriesByDate(date);
      return Right(entries);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomerTransactionDetail>>> getCustomerDetailsForEntry(
      String dailyEntryId) async {
    try {
      final details = await remoteDataSource.getCustomerDetailsForEntry(dailyEntryId);
      return Right(details);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
