import '../../core/error/exceptions.dart';
import '../../core/utils/type_converters.dart';
import '../models/bill_model.dart';
import 'neon_database.dart';

abstract class BillRemoteDataSource {
  Future<String> generateMonthlyBill({
    required String customerId,
    required int year,
    required int month,
  });
  Future<BillModel> getBillDetails(String billId);
  Future<List<BillModel>> getAllBills();
  Future<List<BillModel>> getCustomerBills(String customerId);
  Future<void> deleteBill(String billId);
}

class BillRemoteDataSourceImpl implements BillRemoteDataSource {
  final NeonDatabase database;

  BillRemoteDataSourceImpl({required this.database});

  @override
  Future<String> generateMonthlyBill({
    required String customerId,
    required int year,
    required int month,
  }) async {
    try {
      final result = await database.connection.execute(
        'SELECT generate_monthly_bill(\$1, \$2, \$3)',
        parameters: [customerId, year, month],
      );

      return result.first[0] as String;
    } catch (e) {
      throw DatabaseException('Failed to generate bill: $e');
    }
  }

  @override
  Future<BillModel> getBillDetails(String billId) async {
    try {
      // Get bill header with customer name
      final billResult = await database.connection.execute(
        '''
        SELECT b.*, c.name as customer_name
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

      return BillModel(
        id: billRow[0] as String,
        billNumber: billRow[1] as String,
        customerId: billRow[2] as String,
        customerName: billRow[12] as String,
        billYear: billRow[3] as int,
        billMonth: billRow[4] as int,
        totalQuantity: TypeConverters.toDouble(billRow[5]),
        totalAmount: TypeConverters.toDouble(billRow[6]),
        totalCommission: TypeConverters.toDouble(billRow[7]),
        totalAdvance: TypeConverters.toDouble(billRow[8]),
        totalExpense: TypeConverters.toDouble(billRow[9]),
        netAmount: TypeConverters.toDouble(billRow[10]),
        status: billRow[11] as String,
        generatedAt: generatedAt,
        items: items,
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
  Future<List<BillModel>> getAllBills() async {
    try {
      final result = await database.connection.execute(
        '''
        SELECT b.*, c.name as customer_name
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
          customerName: row[12] as String,
          billYear: row[3] as int,
          billMonth: row[4] as int,
          totalQuantity: TypeConverters.toDouble(row[5]),
          totalAmount: TypeConverters.toDouble(row[6]),
          totalCommission: TypeConverters.toDouble(row[7]),
          totalAdvance: TypeConverters.toDouble(row[8]),
          totalExpense: TypeConverters.toDouble(row[9]),
          netAmount: TypeConverters.toDouble(row[10]),
          status: row[11] as String,
          generatedAt: row[12] as DateTime,
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
        SELECT b.*, c.name as customer_name
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
          customerName: row[12] as String,
          billYear: row[3] as int,
          billMonth: row[4] as int,
          totalQuantity: TypeConverters.toDouble(row[5]),
          totalAmount: TypeConverters.toDouble(row[6]),
          totalCommission: TypeConverters.toDouble(row[7]),
          totalAdvance: TypeConverters.toDouble(row[8]),
          totalExpense: TypeConverters.toDouble(row[9]),
          netAmount: TypeConverters.toDouble(row[10]),
          status: row[11] as String,
          generatedAt: row[12] as DateTime,
          items: const [],
        );
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get customer bills: $e');
    }
  }
}
