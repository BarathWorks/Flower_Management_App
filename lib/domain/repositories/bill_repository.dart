import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/bill.dart';

abstract class BillRepository {
  Future<Either<Failure, String>> generateMonthlyBill({
    required String customerId,
    required int year,
    required int month,
  });
  Future<Either<Failure, Bill>> getBillDetails(String billId);
  Future<Either<Failure, List<Bill>>> getAllBills();
  Future<Either<Failure, List<Bill>>> getCustomerBills(String customerId);
}
