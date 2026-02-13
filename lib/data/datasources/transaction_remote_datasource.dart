import '../../core/error/exceptions.dart';
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
        WHERE dfe.entry_date = @date
        ORDER BY dfc.created_at DESC
        ''',
        parameters: {'date': date.toIso8601String().split('T')[0]},
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
          quantity: (row[7] as num).toDouble(),
          rate: (row[8] as num).toDouble(),
          amount: (row[9] as num).toDouble(),
          commission: (row[10] as num).toDouble(),
          netAmount: (row[11] as num).toDouble(),
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
        VALUES (@date, @flowerId)
        ON CONFLICT (entry_date, flower_id) 
        DO UPDATE SET entry_date = EXCLUDED.entry_date
        RETURNING id
        ''',
        parameters: {
          'date': dateStr,
          'flowerId': flowerId,
        },
      );

      final dailyEntryId = entryResult.first[0] as String;

      // Then, insert the customer transaction
      await database.connection.execute(
        '''
        INSERT INTO daily_flower_customer 
        (daily_entry_id, customer_id, quantity, rate, amount, commission, net_amount)
        VALUES (@entryId, @customerId, @quantity, @rate, @amount, @commission, @netAmount)
        ''',
        parameters: {
          'entryId': dailyEntryId,
          'customerId': customerId,
          'quantity': quantity,
          'rate': rate,
          'amount': amount,
          'commission': commission,
          'netAmount': netAmount,
        },
      );
    } catch (e) {
      throw DatabaseException('Failed to add transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await database.connection.execute(
        'DELETE FROM daily_flower_customer WHERE id = @id',
        parameters: {'id': transactionId},
      );
    } catch (e) {
      throw DatabaseException('Failed to delete transaction: $e');
    }
  }
}
