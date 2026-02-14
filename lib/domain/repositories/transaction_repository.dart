import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/daily_flower_entry.dart';
import '../entities/customer_transaction_detail.dart';
import '../usecases/transaction/add_transaction.dart';

abstract class TransactionRepository {
  // Legacy methods (for backward compatibility)
  Future<Either<Failure, List<Transaction>>> getTodayTransactions();
  Future<Either<Failure, List<Transaction>>> getTransactionsByDate(
      DateTime date);
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  // New methods for daily flower entries
  Future<Either<Failure, List<DailyFlowerEntry>>> getTodayDailyEntries();
  Future<Either<Failure, List<DailyFlowerEntry>>> getDailyEntriesByDate(
      DateTime date);
  Future<Either<Failure, List<CustomerTransactionDetail>>> getCustomerDetailsForEntry(
      String dailyEntryId);
  
  Future<Either<Failure, void>> addTransaction({
    required String flowerId,
    required String customerId,
    required DateTime entryDate,
    required double quantity,
    required double rate,
    required double commission,
  });
  Future<Either<Failure, void>> addMultipleCustomerTransactions({
    required String flowerId,
    required DateTime entryDate,
    required List<CustomerTransactionData> customers,
  });
  Future<Either<Failure, void>> deleteTransaction(String transactionId);
}
