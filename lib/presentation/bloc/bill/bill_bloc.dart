import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/bill/generate_monthly_bill.dart';
import '../../../domain/usecases/bill/get_all_bills.dart';
import '../../../domain/usecases/bill/get_bill_details.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final GetAllBills getAllBills;
  final GetBillDetails getBillDetails;
  final GenerateMonthlyBill generateMonthlyBill;

  BillBloc({
    required this.getAllBills,
    required this.getBillDetails,
    required this.generateMonthlyBill,
  }) : super(BillInitial()) {
    on<LoadAllBills>(_onLoadAllBills);
    on<LoadBillDetails>(_onLoadBillDetails);
    on<GenerateBillEvent>(_onGenerateBill);
    on<RefreshBills>(_onRefreshBills);
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
    final result = await generateMonthlyBill(GenerateMonthlyBillParams(
      customerId: event.customerId,
      year: event.year,
      month: event.month,
    ));

    await result.fold(
      (failure) async => emit(BillError(failure.message)),
      (billId) async {
        emit(const BillOperationSuccess('Bill generated successfully'));
        add(LoadAllBills());
      },
    );
  }

  Future<void> _onRefreshBills(
    RefreshBills event,
    Emitter<BillState> emit,
  ) async {
    add(LoadAllBills());
  }
}
