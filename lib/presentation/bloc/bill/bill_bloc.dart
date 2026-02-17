import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/bill/generate_bill.dart';
import '../../../domain/usecases/bill/get_last_bill_date.dart';
import '../../../domain/usecases/bill/delete_bill.dart';
import '../../../domain/usecases/bill/get_all_bills.dart';
import '../../../domain/usecases/bill/get_bill_details.dart';
import '../../../domain/usecases/bill/update_bill_status.dart';
import '../../../domain/usecases/bill/add_payment.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final GetAllBills getAllBills;
  final GetBillDetails getBillDetails;
  final GenerateBill generateBill;
  final GetLastBillDate getLastBillDate;
  final DeleteBill deleteBill;
  final UpdateBillStatus updateBillStatus;
  final AddPayment addPayment;

  BillBloc({
    required this.getAllBills,
    required this.getBillDetails,
    required this.generateBill,
    required this.getLastBillDate,
    required this.deleteBill,
    required this.updateBillStatus,
    required this.addPayment,
  }) : super(BillInitial()) {
    on<LoadAllBills>(_onLoadAllBills);
    on<LoadBillDetails>(_onLoadBillDetails);
    on<GenerateBillEvent>(_onGenerateBill);
    on<LoadLastBillDate>(_onLoadLastBillDate);
    on<RefreshBills>(_onRefreshBills);
    on<DeleteBillEvent>(_onDeleteBill);
    on<UpdateBillStatusEvent>(_onUpdateBillStatus);
    on<AddPaymentEvent>(_onAddPayment);
  }

  Future<void> _onLoadAllBills(
    LoadAllBills event,
    Emitter<BillState> emit,
  ) async {
    emit(BillLoading());
    final result = await getAllBills(const NoParams());
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (bills) => emit(BillListLoaded(bills)),
    );
  }

  Future<void> _onLoadBillDetails(
    LoadBillDetails event,
    Emitter<BillState> emit,
  ) async {
    emit(BillLoading());
    final result = await getBillDetails(event.billId);
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (bill) => emit(BillDetailsLoaded(bill)),
    );
  }

  Future<void> _onGenerateBill(
    GenerateBillEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(BillLoading());
    final result = await generateBill(GenerateBillParams(
      customerId: event.customerId,
      startDate: event.startDate,
      endDate: event.endDate,
    ));

    await result.fold(
      (failure) async => emit(BillError(failure.message)),
      (billId) async {
        emit(const BillOperationSuccess('Bill generated successfully'));
        add(LoadAllBills());
      },
    );
  }

  Future<void> _onLoadLastBillDate(
    LoadLastBillDate event,
    Emitter<BillState> emit,
  ) async {
    // We don't want to show a full screen loading indicator for this,
    // effectively "silently" loading or handling fetch state in UI if needed.
    // However, if fetching, we might want to emit a specific loading state if the UI depends on it.
    // For now, we will just emit the result.
    final result = await getLastBillDate(event.customerId);
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (date) => emit(LastBillDateLoaded(date)),
    );
  }

  Future<void> _onRefreshBills(
    RefreshBills event,
    Emitter<BillState> emit,
  ) async {
    add(LoadAllBills());
  }

  Future<void> _onDeleteBill(
    DeleteBillEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(BillLoading());
    final result = await deleteBill(event.billId);
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (_) {
        emit(const BillOperationSuccess('Bill deleted successfully'));
        add(LoadAllBills());
      },
    );
  }

  Future<void> _onUpdateBillStatus(
    UpdateBillStatusEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(BillLoading());
    final result = await updateBillStatus(
      UpdateBillStatusParams(billId: event.billId, status: event.status),
    );
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (_) {
        emit(const BillOperationSuccess('Bill status updated successfully'));
        add(LoadBillDetails(event.billId));
      },
    );
  }

  Future<void> _onAddPayment(
    AddPaymentEvent event,
    Emitter<BillState> emit,
  ) async {
    emit(BillLoading());
    final result = await addPayment(
      AddPaymentParams(
        billId: event.billId,
        amount: event.amount,
        date: event.date,
        notes: event.notes,
      ),
    );
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (_) {
        emit(const BillOperationSuccess('Payment added successfully'));
        add(LoadBillDetails(event.billId));
      },
    );
  }
}
