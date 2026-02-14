import 'package:get_it/get_it.dart';
import 'data/datasources/bill_remote_datasource.dart';
import 'data/datasources/customer_remote_datasource.dart';
import 'data/datasources/dashboard_remote_datasource.dart';
import 'data/datasources/flower_remote_datasource.dart';
import 'data/datasources/neon_database.dart';
import 'data/datasources/transaction_remote_datasource.dart';
import 'data/repositories/bill_repository_impl.dart';
import 'data/repositories/customer_repository_impl.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'data/repositories/flower_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'domain/repositories/bill_repository.dart';
import 'domain/repositories/customer_repository.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/repositories/flower_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/usecases/bill/generate_monthly_bill.dart';
import 'domain/usecases/bill/get_all_bills.dart';
import 'domain/usecases/bill/get_bill_details.dart';
import 'domain/usecases/customer/add_customer.dart';
import 'domain/usecases/customer/delete_customer.dart';
import 'domain/usecases/customer/get_all_customers.dart';
import 'domain/usecases/customer/get_customers_without_bills.dart';
import 'domain/usecases/customer/update_customer.dart';
import 'domain/usecases/dashboard/get_dashboard_summary.dart';
import 'domain/usecases/flower/add_flower.dart';
import 'domain/usecases/flower/delete_flower.dart';
import 'domain/usecases/flower/get_all_flowers.dart';
import 'domain/usecases/transaction/add_transaction.dart';
import 'domain/usecases/transaction/delete_transaction.dart';
import 'domain/usecases/transaction/get_today_transactions.dart';
import 'domain/usecases/transaction/get_transactions_by_date.dart';
import 'domain/usecases/transaction/get_today_daily_entries.dart';
import 'domain/usecases/transaction/get_daily_entries_by_date.dart';
import 'domain/usecases/transaction/get_customer_details_for_entry.dart';
import 'presentation/bloc/bill/bill_bloc.dart';
import 'presentation/bloc/customer/customer_bloc.dart';
import 'presentation/bloc/dashboard/dashboard_bloc.dart';
import 'presentation/bloc/flower/flower_bloc.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Dashboard
  // Bloc
  sl.registerFactory(
    () => DashboardBloc(
      getDashboardSummary: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDashboardSummary(sl()));

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(database: sl()),
  );

  //! Features - Transaction
  // Bloc
  sl.registerFactory(
    () => TransactionBloc(
      getTodayTransactions: sl(),
      getTransactionsByDate: sl(),
      getTodayDailyEntries: sl(),
      getDailyEntriesByDate: sl(),
      getCustomerDetailsForEntry: sl(),
      addTransaction: sl(),
      deleteTransaction: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTodayTransactions(sl()));
  sl.registerLazySingleton(() => GetTransactionsByDate(sl()));
  sl.registerLazySingleton(() => GetTodayDailyEntries(sl()));
  sl.registerLazySingleton(() => GetDailyEntriesByDate(sl()));
  sl.registerLazySingleton(() => GetCustomerDetailsForEntry(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(database: sl()),
  );

  //! Features - Customer
  // Bloc
  sl.registerFactory(
    () => CustomerBloc(
      getAllCustomers: sl(),
      addCustomer: sl(),
      updateCustomer: sl(),
      deleteCustomer: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllCustomers(sl()));
  sl.registerLazySingleton(() => GetCustomersWithoutBills(sl()));
  sl.registerLazySingleton(() => AddCustomer(sl()));
  sl.registerLazySingleton(() => UpdateCustomer(sl()));
  sl.registerLazySingleton(() => DeleteCustomer(sl()));

  // Repository
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(database: sl()),
  );

  //! Features - Flower
  // Bloc
  sl.registerFactory(
    () => FlowerBloc(
      getAllFlowers: sl(),
      addFlower: sl(),
      deleteFlower: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllFlowers(sl()));
  sl.registerLazySingleton(() => AddFlower(sl()));
  sl.registerLazySingleton(() => DeleteFlower(sl()));

  // Repository
  sl.registerLazySingleton<FlowerRepository>(
    () => FlowerRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<FlowerRemoteDataSource>(
    () => FlowerRemoteDataSourceImpl(database: sl()),
  );

  //! Features - Bill
  // Bloc
  sl.registerFactory(
    () => BillBloc(
      getAllBills: sl(),
      getBillDetails: sl(),
      generateMonthlyBill: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllBills(sl()));
  sl.registerLazySingleton(() => GetBillDetails(sl()));
  sl.registerLazySingleton(() => GenerateMonthlyBill(sl()));

  // Repository
  sl.registerLazySingleton<BillRepository>(
    () => BillRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BillRemoteDataSource>(
    () => BillRemoteDataSourceImpl(database: sl()),
  );

  //! Core
  // Database
  sl.registerLazySingleton(() => NeonDatabase.instance);
}
