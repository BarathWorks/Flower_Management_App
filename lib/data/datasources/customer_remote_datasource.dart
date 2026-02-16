import '../../core/error/exceptions.dart';
import '../models/customer_model.dart';
import 'neon_database.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getAllCustomers();
  Future<List<CustomerModel>> getCustomersWithoutBills({
    required int year,
    required int month,
  });
  Future<CustomerModel> getCustomerById(String id);
  Future<void> addCustomer({
    required String name,
    String? phone,
    String? address,
    double? defaultCommission,
    List<String> flowerIds,
  });
  Future<void> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? address,
    double? defaultCommission,
    List<String> flowerIds,
  });
  Future<void> deleteCustomer(String id);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final NeonDatabase database;

  CustomerRemoteDataSourceImpl({required this.database});

  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final result = await database.connection.execute(
        'SELECT c.id, c.name, c.phone, c.address, c.created_at, c.default_commission, '
        'array_remove(array_agg(cf.flower_id), NULL) as flower_ids '
        'FROM customers c '
        'LEFT JOIN customer_flowers cf ON c.id = cf.customer_id '
        'GROUP BY c.id, c.name, c.phone, c.address, c.created_at, c.default_commission '
        'ORDER BY c.name ASC',
      );

      return result.map((row) {
        return CustomerModel(
          id: row[0] as String,
          name: row[1] as String,
          phone: row[2] as String?,
          address: row[3] as String?,
          createdAt: row[4] as DateTime,
          defaultCommission: row[5] as double?,
          flowerIds:
              (row[6] as List<dynamic>?)?.map((e) => e as String).toList() ??
                  [],
        );
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get customers: $e');
    }
  }

  @override
  Future<List<CustomerModel>> getCustomersWithoutBills({
    required int year,
    required int month,
  }) async {
    try {
      // Note: This query might be more complex with GROUP BY and LEFT JOINs together.
      // For simplicity in this specific use case (generating bills), we might not need flower_ids strictly,
      // but to be consistent with the model, we should probably fetch them.
      // However, fetching them for "customers without bills" might be overkill if we just need to list them.
      // Let's stick to the main query but add the group by and aggregation.

      final result = await database.connection.execute(
        'SELECT c.id, c.name, c.phone, c.address, c.created_at, c.default_commission, '
        'array_remove(array_agg(cf.flower_id), NULL) as flower_ids '
        'FROM customers c '
        'LEFT JOIN bills b ON c.id = b.customer_id AND b.bill_year = \$1 AND b.bill_month = \$2 '
        'LEFT JOIN customer_flowers cf ON c.id = cf.customer_id '
        'WHERE b.id IS NULL '
        'GROUP BY c.id, c.name, c.phone, c.address, c.created_at, c.default_commission '
        'ORDER BY c.name ASC',
        parameters: [year, month],
      );

      return result.map((row) {
        return CustomerModel(
          id: row[0] as String,
          name: row[1] as String,
          phone: row[2] as String?,
          address: row[3] as String?,
          createdAt: row[4] as DateTime,
          defaultCommission: row[5] as double?,
          flowerIds:
              (row[6] as List<dynamic>?)?.map((e) => e as String).toList() ??
                  [],
        );
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get customers without bills: $e');
    }
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    try {
      final result = await database.connection.execute(
        'SELECT c.id, c.name, c.phone, c.address, c.created_at, c.default_commission, '
        'array_remove(array_agg(cf.flower_id), NULL) as flower_ids '
        'FROM customers c '
        'LEFT JOIN customer_flowers cf ON c.id = cf.customer_id '
        'WHERE c.id = \$1 '
        'GROUP BY c.id, c.name, c.phone, c.address, c.created_at, c.default_commission',
        parameters: [id],
      );

      if (result.isEmpty) {
        throw DatabaseException('Customer not found');
      }

      final row = result.first;
      return CustomerModel(
        id: row[0] as String,
        name: row[1] as String,
        phone: row[2] as String?,
        address: row[3] as String?,
        createdAt: row[4] as DateTime,
        defaultCommission: row[5] as double?,
        flowerIds:
            (row[6] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      );
    } catch (e) {
      throw DatabaseException('Failed to get customer: $e');
    }
  }

  @override
  Future<void> addCustomer({
    required String name,
    String? phone,
    String? address,
    double? defaultCommission,
    List<String> flowerIds = const [],
  }) async {
    try {
      await database.connection.runTx((session) async {
        final result = await session.execute(
          'INSERT INTO customers (name, phone, address, default_commission) VALUES (\$1, \$2, \$3, \$4) RETURNING id',
          parameters: [name, phone, address, defaultCommission],
        );

        final customerId = result.first[0] as String;

        if (flowerIds.isNotEmpty) {
          for (final flowerId in flowerIds) {
            await session.execute(
              'INSERT INTO customer_flowers (customer_id, flower_id) VALUES (\$1, \$2)',
              parameters: [customerId, flowerId],
            );
          }
        }
      });
    } catch (e) {
      throw DatabaseException('Failed to add customer: $e');
    }
  }

  @override
  Future<void> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? address,
    double? defaultCommission,
    List<String> flowerIds = const [],
  }) async {
    try {
      await database.connection.runTx((session) async {
        await session.execute(
          'UPDATE customers SET name = \$2, phone = \$3, address = \$4, default_commission = \$5 WHERE id = \$1',
          parameters: [id, name, phone, address, defaultCommission],
        );

        // Delete existing associations
        await session.execute(
          'DELETE FROM customer_flowers WHERE customer_id = \$1',
          parameters: [id],
        );

        // Insert new associations
        if (flowerIds.isNotEmpty) {
          for (final flowerId in flowerIds) {
            await session.execute(
              'INSERT INTO customer_flowers (customer_id, flower_id) VALUES (\$1, \$2)',
              parameters: [id, flowerId],
            );
          }
        }
      });
    } catch (e) {
      throw DatabaseException('Failed to update customer: $e');
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      // ON DELETE CASCADE should handle the customer_flowers table
      await database.connection.execute(
        'DELETE FROM customers WHERE id = \$1',
        parameters: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete customer: $e');
    }
  }
}
