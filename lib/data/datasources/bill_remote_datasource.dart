import '../../core/error/exceptions.dart';
import '../../core/utils/type_converters.dart';
import '../models/bill_model.dart';
import '../models/payment_model.dart';
import 'neon_database.dart';

abstract class BillRemoteDataSource {
  Future<String> generateBill({
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<DateTime?> getLastBillDate(String customerId);
  Future<BillModel> getBillDetails(String billId);
  Future<List<BillModel>> getAllBills();
  Future<List<BillModel>> getCustomerBills(String customerId);
  Future<void> deleteBill(String billId);
  Future<void> updateBillStatus(String billId, String status);
  Future<void> addPayment({
    required String billId,
    required double amount,
    required DateTime date,
    String? notes,
  });
}

class BillRemoteDataSourceImpl implements BillRemoteDataSource {
  final NeonDatabase database;

  BillRemoteDataSourceImpl({required this.database});

  @override
  Future<String> generateBill({
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await database.connection.execute(
        'SELECT generate_bill(\$1, \$2, \$3)',
        parameters: [customerId, startDate, endDate],
      );

      return result.first[0] as String;
    } catch (e) {
      throw DatabaseException('Failed to generate bill: $e');
    }
  }

  @override
  Future<DateTime?> getLastBillDate(String customerId) async {
    try {
      final result = await database.connection.execute(
        '''
        SELECT end_date 
        FROM bills 
        WHERE customer_id = \$1 
        ORDER BY end_date DESC 
        LIMIT 1
        ''',
        parameters: [customerId],
      );

      if (result.isEmpty) {
        return null;
      }

      return result.first[0] as DateTime?;
    } catch (e) {
      throw DatabaseException('Failed to get last bill date: $e');
    }
  }

  @override
  Future<void> addPayment({
    required String billId,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    try {
      // 1. Insert payment
      await database.connection.execute(
        'INSERT INTO payments (bill_id, amount, payment_date, notes) VALUES (\$1, \$2, \$3, \$4)',
        parameters: [billId, amount, date, notes],
      );

      // 2. Update bill paid_amount and status
      await database.connection.execute(
        '''
        UPDATE bills 
        SET 
          paid_amount = COALESCE(paid_amount, 0) + \$1,
          status = CASE 
            WHEN (COALESCE(paid_amount, 0) + \$1) >= net_amount THEN 'PAID'
            WHEN (COALESCE(paid_amount, 0) + \$1) > 0 THEN 'PARTIAL'
            ELSE 'UNPAID'
          END
        WHERE id = \$2
        ''',
        parameters: [amount, billId],
      );
    } catch (e) {
      throw DatabaseException('Failed to add payment: $e');
    }
  }

  @override
  Future<BillModel> getBillDetails(String billId) async {
    try {
      // Get bill header with customer name
      final billResult = await database.connection.execute(
        '''
        SELECT 
          b.id,                -- 0
          b.bill_number,       -- 1
          b.customer_id,       -- 2
          b.bill_year,         -- 3
          b.bill_month,        -- 4
          b.total_quantity,    -- 5
          b.total_amount,      -- 6
          b.total_commission,  -- 7
          b.total_expense,     -- 8
          b.net_amount,        -- 9
          b.status,            -- 10
          b.generated_at,      -- 11
          COALESCE(b.total_advance, 0) as total_advance, -- 12
          c.name as customer_name, -- 13
          b.start_date,        -- 14
          b.end_date,          -- 15
          COALESCE(b.paid_amount, 0) as paid_amount -- 16
        FROM bills b
        JOIN customers c ON b.customer_id = c.id
        WHERE b.id = \$1
        ''',
        parameters: [billId],
      );

      if (billResult.isEmpty) {
        throw DatabaseException('Bill not found');
      }

      // Get bill items with flower names
      final itemsResult = await database.connection.execute(
        '''
        SELECT 
          bi.id,
          bi.flower_id,
          bi.total_quantity,
          bi.total_amount,
          bi.total_commission,
          bi.net_amount,
          f.name as flower_name
        FROM bill_items bi
        JOIN flowers f ON bi.flower_id = f.id
        WHERE bi.bill_id = \$1
        ORDER BY f.name ASC
        ''',
        parameters: [billId],
      );

      // Get payments
      final paymentsResult = await database.connection.execute(
        '''
        SELECT id, bill_id, amount, payment_date, notes
        FROM payments
        WHERE bill_id = \$1
        ORDER BY payment_date DESC
        ''',
        parameters: [billId],
      );

      final billRow = billResult.first;
      final generatedAt = billRow[11] as DateTime;

      final items = itemsResult.map((row) {
        final totalQuantity = TypeConverters.toDouble(row[2]);
        final totalAmount = TypeConverters.toDouble(row[3]);
        final rate = totalQuantity > 0 ? totalAmount / totalQuantity : 0.0;

        return BillItemModel(
          id: row[0] as String,
          flowerId: row[1] as String,
          flowerName: row[6] as String,
          quantity: totalQuantity,
          totalAmount: totalAmount,
          totalCommission: TypeConverters.toDouble(row[4]),
          date: generatedAt,
          rate: rate,
          netAmount: TypeConverters.toDouble(row[5]),
        );
      }).toList();

      final payments = paymentsResult.map((row) {
        return PaymentModel.fromDatabase(row);
      }).toList();

      return BillModel(
        id: billRow[0] as String,
        billNumber: billRow[1] as String,
        customerId: billRow[2] as String,
        customerName: billRow[13] as String,
        billYear: billRow[3] as int,
        billMonth: billRow[4] as int,
        startDate: billRow[14] as DateTime?,
        endDate: billRow[15] as DateTime?,
        totalQuantity: TypeConverters.toDouble(billRow[5]),
        totalAmount: TypeConverters.toDouble(billRow[6]),
        totalCommission: TypeConverters.toDouble(billRow[7]),
        totalAdvance: TypeConverters.toDouble(billRow[12]),
        totalExpense: TypeConverters.toDouble(billRow[8]),
        netAmount: TypeConverters.toDouble(billRow[9]),
        paidAmount: TypeConverters.toDouble(billRow[16]),
        status: billRow[10] as String,
        generatedAt: generatedAt,
        items: items,
        payments: payments,
      );
    } catch (e) {
      throw DatabaseException('Failed to get bill details: $e');
    }
  }

  @override
  Future<void> deleteBill(String billId) async {
    try {
      await database.connection.execute(
        'DELETE FROM bills WHERE id = \$1',
        parameters: [billId],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete bill: $e');
    }
  }

  @override
  Future<void> updateBillStatus(String billId, String status) async {
    try {
      await database.connection.execute(
        'UPDATE bills SET status = \$1 WHERE id = \$2',
        parameters: [status, billId],
      );
    } catch (e) {
      throw DatabaseException('Failed to update bill status: $e');
    }
  }

  @override
  Future<List<BillModel>> getAllBills() async {
    try {
      final result = await database.connection.execute(
        '''
        SELECT 
          b.id,                -- 0
          b.bill_number,       -- 1
          b.customer_id,       -- 2
          b.bill_year,         -- 3
          b.bill_month,        -- 4
          b.total_quantity,    -- 5
          b.total_amount,      -- 6
          b.total_commission,  -- 7
          b.total_expense,     -- 8
          b.net_amount,        -- 9
          b.status,            -- 10
          b.generated_at,      -- 11
          COALESCE(b.total_advance, 0) as total_advance, -- 12
          c.name as customer_name, -- 13
          b.start_date,        -- 14
          b.end_date,          -- 15
          COALESCE(b.paid_amount, 0) as paid_amount -- 16
        FROM bills b
        JOIN customers c ON b.customer_id = c.id
        ORDER BY b.generated_at DESC
        ''',
      );

      return result.map((row) {
        return BillModel(
          id: row[0] as String,
          billNumber: row[1] as String,
          customerId: row[2] as String,
          customerName: row[13] as String,
          billYear: row[3] as int,
          billMonth: row[4] as int,
          startDate: row[14] as DateTime?,
          endDate: row[15] as DateTime?,
          totalQuantity: TypeConverters.toDouble(row[5]),
          totalAmount: TypeConverters.toDouble(row[6]),
          totalCommission: TypeConverters.toDouble(row[7]),
          totalAdvance: TypeConverters.toDouble(row[12]),
          totalExpense: TypeConverters.toDouble(row[8]),
          netAmount: TypeConverters.toDouble(row[9]),
          paidAmount: TypeConverters.toDouble(row[16]),
          status: row[10] as String,
          generatedAt: row[11] as DateTime,
          items: const [],
        );
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get bills: $e');
    }
  }

  @override
  Future<List<BillModel>> getCustomerBills(String customerId) async {
    try {
      final result = await database.connection.execute(
        '''
        SELECT 
          b.id,                -- 0
          b.bill_number,       -- 1
          b.customer_id,       -- 2
          b.bill_year,         -- 3
          b.bill_month,        -- 4
          b.total_quantity,    -- 5
          b.total_amount,      -- 6
          b.total_commission,  -- 7
          b.total_expense,     -- 8
          b.net_amount,        -- 9
          b.status,            -- 10
          b.generated_at,      -- 11
          COALESCE(b.total_advance, 0) as total_advance, -- 12
          c.name as customer_name, -- 13
          b.start_date,        -- 14
          b.end_date,          -- 15
          COALESCE(b.paid_amount, 0) as paid_amount -- 16
        FROM bills b
        JOIN customers c ON b.customer_id = c.id
        WHERE b.customer_id = \$1
        ORDER BY b.generated_at DESC
        ''',
        parameters: [customerId],
      );

      return result.map((row) {
        return BillModel(
          id: row[0] as String,
          billNumber: row[1] as String,
          customerId: row[2] as String,
          customerName: row[13] as String,
          billYear: row[3] as int,
          billMonth: row[4] as int,
          startDate: row[14] as DateTime?,
          endDate: row[15] as DateTime?,
          totalQuantity: TypeConverters.toDouble(row[5]),
          totalAmount: TypeConverters.toDouble(row[6]),
          totalCommission: TypeConverters.toDouble(row[7]),
          totalAdvance: TypeConverters.toDouble(row[12]),
          totalExpense: TypeConverters.toDouble(row[8]),
          netAmount: TypeConverters.toDouble(row[9]),
          paidAmount: TypeConverters.toDouble(row[16]),
          status: row[10] as String,
          generatedAt: row[11] as DateTime,
          items: const [],
        );
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get customer bills: $e');
    }
  }
}
