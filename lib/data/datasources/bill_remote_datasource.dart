import '../../core/error/exceptions.dart';
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
        'SELECT generate_monthly_bill(@customerId, @year, @month)',
        parameters: {
          'customerId': customerId,
          'year': year,
          'month': month,
        },
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
        WHERE b.id = @billId
        ''',
        parameters: {'billId': billId},
      );

      if (billResult.isEmpty) {
        throw DatabaseException('Bill not found');
      }

      // Get bill items with flower names
      final itemsResult = await database.connection.execute(
        '''
        SELECT bi.*, f.name as flower_name
        FROM bill_items bi
        JOIN flowers f ON bi.flower_id = f.id
        WHERE bi.bill_id = @billId
        ''',
        parameters: {'billId': billId},
      );

      final billRow = billResult.first;
      final items = itemsResult.map((row) {
        return BillItemModel(
          id: row[0] as String,
          flowerId: row[2] as String,
          flowerName: row[6] as String,
          totalQuantity: (row[3] as num).toDouble(),
          totalAmount: (row[4] as num).toDouble(),
          totalCommission: (row[5] as num).toDouble(),
          netAmount: (row[3] as num).toDouble(),
        );
      }).toList();

      return BillModel(
        id: billRow[0] as String,
        billNumber: billRow[1] as String,
        customerId: billRow[2] as String,
        customerName: billRow[12] as String,
        billYear: billRow[3] as int,
        billMonth: billRow[4] as int,
        totalQuantity: (billRow[5] as num).toDouble(),
        totalAmount: (billRow[6] as num).toDouble(),
        totalCommission: (billRow[7] as num).toDouble(),
        totalExpense: (billRow[8] as num).toDouble(),
        netAmount: (billRow[9] as num).toDouble(),
        status: billRow[10] as String,
        generatedAt: billRow[11] as DateTime,
        items: items,
      );
    } catch (e) {
      throw DatabaseException('Failed to get bill details: $e');
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
          totalQuantity: (row[5] as num).toDouble(),
          totalAmount: (row[6] as num).toDouble(),
          totalCommission: (row[7] as num).toDouble(),
          totalExpense: (row[8] as num).toDouble(),
          netAmount: (row[9] as num).toDouble(),
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
        SELECT b.*, c.name as customer_name
        FROM bills b
        JOIN customers c ON b.customer_id = c.id
        WHERE b.customer_id = @customerId
        ORDER BY b.generated_at DESC
        ''',
        parameters: {'customerId': customerId},
      );

      return result.map((row) {
        return BillModel(
          id: row[0] as String,
          billNumber: row[1] as String,
          customerId: row[2] as String,
          customerName: row[12] as String,
          billYear: row[3] as int,
          billMonth: row[4] as int,
          totalQuantity: (row[5] as num).toDouble(),
          totalAmount: (row[6] as num).toDouble(),
          totalCommission: (row[7] as num).toDouble(),
          totalExpense: (row[8] as num).toDouble(),
          netAmount: (row[9] as num).toDouble(),
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
