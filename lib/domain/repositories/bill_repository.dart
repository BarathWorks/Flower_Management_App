import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/bill.dart';

abstract class BillRepository {
  Future<Either<Failure, String>> generateBill({
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<Either<Failure, DateTime?>> getLastBillDate(String customerId);
  Future<Either<Failure, Bill>> getBillDetails(String billId);
  Future<Either<Failure, List<Bill>>> getAllBills();
  Future<Either<Failure, List<Bill>>> getCustomerBills(String customerId);
  Future<Either<Failure, void>> deleteBill(String billId);
  Future<Either<Failure, void>> updateBillStatus(String billId, String status);
  Future<Either<Failure, void>> addPayment({
    required String billId,
    required double amount,
    required DateTime date,
    String? notes,
  });
}
