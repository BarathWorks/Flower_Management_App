import '../../core/error/exceptions.dart';
import '../../core/utils/type_converters.dart';
import '../models/transaction_model.dart';
import 'neon_database.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTodayTransactions();
  Future<List<TransactionModel>> getTransactionsByDate(DateTime date);
  Future<void> addTransaction({
    required String flowerId,
    required String customerId,
    required DateTime entryDate,
    required double quantity,
    required double rate,
    required double commission,
  });
  Future<void> deleteTransaction(String transactionId);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final NeonDatabase database;

  TransactionRemoteDataSourceImpl({required this.database});

  @override
  Future<List<TransactionModel>> getTodayTransactions() async {
    return getTransactionsByDate(DateTime.now());
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDate(DateTime date) async {
    try {
      final result = await database.connection.execute(
        '''
        SELECT 
          dfc.id,
          dfc.daily_entry_id,
          dfc.customer_id,
          c.name as customer_name,
          dfe.flower_id,
          f.name as flower_name,
          dfe.entry_date,
          dfc.quantity,
          dfc.rate,
          dfc.amount,
          dfc.commission,
          dfc.net_amount,
          dfc.created_at
        FROM daily_flower_customer dfc
        JOIN daily_flower_entry dfe ON dfc.daily_entry_id = dfe.id
        JOIN customers c ON dfc.customer_id = c.id
        JOIN flowers f ON dfe.flower_id = f.id
        WHERE dfe.entry_date = \$1
        ORDER BY dfc.created_at DESC
        ''',
        parameters: [date.toIso8601String().split('T')[0]],
      );

      return result.map((row) {
        return TransactionModel(
          id: row[0] as String,
          dailyEntryId: row[1] as String,
          customerId: row[2] as String,
          customerName: row[3] as String,
          flowerId: row[4] as String,
          flowerName: row[5] as String,
          entryDate: row[6] as DateTime,
          quantity: TypeConverters.toDouble(row[7]),
          rate: TypeConverters.toDouble(row[8]),
          amount: TypeConverters.toDouble(row[9]),
          commission: TypeConverters.toDouble(row[10]),
          netAmount: TypeConverters.toDouble(row[11]),
          createdAt: row[12] as DateTime,
        );
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get transactions: $e');
    }
  }

  @override
  Future<void> addTransaction({
    required String flowerId,
    required String customerId,
    required DateTime entryDate,
    required double quantity,
    required double rate,
    required double commission,
  }) async {
    try {
      final amount = quantity * rate;
      final netAmount = amount - commission;
      final dateStr = entryDate.toIso8601String().split('T')[0];

      // First, get or create daily_flower_entry
      final entryResult = await database.connection.execute(
        '''
        INSERT INTO daily_flower_entry (entry_date, flower_id)
        VALUES (\$1, \$2)
        ON CONFLICT (entry_date, flower_id) 
        DO UPDATE SET entry_date = EXCLUDED.entry_date
        RETURNING id
        ''',
        parameters: [dateStr, flowerId],
      );

      final dailyEntryId = entryResult.first[0] as String;

      // Then, insert the customer transaction
      await database.connection.execute(
        '''
        INSERT INTO daily_flower_customer 
        (daily_entry_id, customer_id, quantity, rate, amount, commission, net_amount)
        VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7)
        ''',
        parameters: [
          dailyEntryId,
          customerId,
          quantity,
          rate,
          amount,
          commission,
          netAmount
        ],
      );
    } catch (e) {
      throw DatabaseException('Failed to add transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await database.connection.execute(
        'DELETE FROM daily_flower_customer WHERE id = \$1',
        parameters: [transactionId],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete transaction: $e');
    }
  }
}
