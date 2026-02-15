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
  });
  Future<void> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? address,
    double? defaultCommission,
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
        'SELECT id, name, phone, address, created_at, default_commission FROM customers ORDER BY name ASC',
      );

      return result.map((row) {
        return CustomerModel(
          id: row[0] as String,
          name: row[1] as String,
          phone: row[2] as String?,
          address: row[3] as String?,
          createdAt: row[4] as DateTime,
          defaultCommission: row[5] as double?,
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
      final result = await database.connection.execute(
        'SELECT DISTINCT c.id, c.name, c.phone, c.address, c.created_at, c.default_commission '
        'FROM customers c '
        'LEFT JOIN bills b ON c.id = b.customer_id '
        'AND b.bill_year = \$1 '
        'AND b.bill_month = \$2 '
        'WHERE b.id IS NULL '
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
        'SELECT id, name, phone, address, created_at, default_commission FROM customers WHERE id = \$1',
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
  }) async {
    try {
      await database.connection.execute(
        'INSERT INTO customers (name, phone, address, default_commission) VALUES (\$1, \$2, \$3, \$4)',
        parameters: [name, phone, address, defaultCommission],
      );
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
  }) async {
    try {
      await database.connection.execute(
        'UPDATE customers SET name = \$2, phone = \$3, address = \$4, default_commission = \$5 WHERE id = \$1',
        parameters: [id, name, phone, address, defaultCommission],
      );
    } catch (e) {
      throw DatabaseException('Failed to update customer: $e');
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await database.connection.execute(
        'DELETE FROM customers WHERE id = \$1',
        parameters: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete customer: $e');
    }
  }
}
