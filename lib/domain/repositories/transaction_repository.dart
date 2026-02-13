import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTodayTransactions();
  Future<Either<Failure, List<Transaction>>> getTransactionsByDate(
      DateTime date);
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<Either<Failure, void>> addTransaction({
    required String flowerId,
    required String customerId,
    required DateTime entryDate,
    required double quantity,
    required double rate,
    required double commission,
  });
  Future<Either<Failure, void>> deleteTransaction(String transactionId);
}
