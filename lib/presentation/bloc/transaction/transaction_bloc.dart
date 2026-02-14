import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/transaction/add_transaction.dart';
import '../../../domain/usecases/transaction/delete_transaction.dart';
import '../../../domain/usecases/transaction/get_today_transactions.dart';
import '../../../domain/usecases/transaction/get_transactions_by_date.dart';
import '../../../domain/usecases/transaction/get_today_daily_entries.dart';
import '../../../domain/usecases/transaction/get_daily_entries_by_date.dart';
import '../../../domain/usecases/transaction/get_customer_details_for_entry.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTodayTransactions getTodayTransactions;
  final GetTransactionsByDate getTransactionsByDate;
  final GetTodayDailyEntries getTodayDailyEntries;
  final GetDailyEntriesByDate getDailyEntriesByDate;
  final GetCustomerDetailsForEntry getCustomerDetailsForEntry;
  final AddTransaction addTransaction;
  final DeleteTransaction deleteTransaction;

  TransactionBloc({
    required this.getTodayTransactions,
    required this.getTransactionsByDate,
    required this.getTodayDailyEntries,
    required this.getDailyEntriesByDate,
    required this.getCustomerDetailsForEntry,
    required this.addTransaction,
    required this.deleteTransaction,
  }) : super(TransactionInitial()) {
    on<LoadTodayTransactions>(_onLoadTodayTransactions);
    on<LoadTransactionsByDate>(_onLoadTransactionsByDate);
    on<LoadTodayDailyEntries>(_onLoadTodayDailyEntries);
    on<LoadDailyEntriesByDate>(_onLoadDailyEntriesByDate);
    on<LoadCustomerDetailsForEntry>(_onLoadCustomerDetailsForEntry);
    on<AddTransactionEvent>(_onAddTransaction);
    on<AddMultipleCustomerTransactionEvent>(_onAddMultipleCustomerTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<RefreshTransactions>(_onRefreshTransactions);
  }

  Future<void> _onLoadTodayTransactions(
    LoadTodayTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getTodayTransactions(const NoParams());
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  Future<void> _onLoadTransactionsByDate(
    LoadTransactionsByDate event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getTransactionsByDate(event.date);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await addTransaction(AddTransactionParams(
      flowerId: event.flowerId,
      entryDate: event.entryDate,
      customers: [
        CustomerTransactionData(
          customerId: event.customerId,
          quantity: event.quantity,
          rate: event.rate,
          commission: event.commission,
        ),
      ],
    ));

    await result.fold(
      (failure) async => emit(TransactionError(failure.message)),
      (_) async {
        emit(const TransactionOperationSuccess(
            'Transaction added successfully'));
        add(LoadTodayTransactions());
      },
    );
  }

  Future<void> _onAddMultipleCustomerTransaction(
    AddMultipleCustomerTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await addTransaction(AddTransactionParams(
      flowerId: event.flowerId,
      entryDate: event.entryDate,
      customers: event.customers,
    ));

    await result.fold(
      (failure) async => emit(TransactionError(failure.message)),
      (_) async {
        emit(TransactionOperationSuccess(
            '${event.customers.length} customer transactions added successfully'));
        add(LoadTodayDailyEntries());
      },
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await deleteTransaction(event.transactionId);

    await result.fold(
      (failure) async => emit(TransactionError(failure.message)),
      (_) async {
        emit(const TransactionOperationSuccess(
            'Transaction deleted successfully'));
        add(LoadTodayDailyEntries());
      },
    );
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    add(LoadTodayDailyEntries());
  }

  Future<void> _onLoadTodayDailyEntries(
    LoadTodayDailyEntries event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getTodayDailyEntries(const NoParams());
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (entries) => emit(DailyEntriesLoaded(entries)),
    );
  }

  Future<void> _onLoadDailyEntriesByDate(
    LoadDailyEntriesByDate event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getDailyEntriesByDate(event.date);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (entries) => emit(DailyEntriesLoaded(entries)),
    );
  }

  Future<void> _onLoadCustomerDetailsForEntry(
    LoadCustomerDetailsForEntry event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getCustomerDetailsForEntry(event.dailyEntryId);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (details) => emit(CustomerDetailsLoaded(details, event.dailyEntryId)),
    );
  }
}
