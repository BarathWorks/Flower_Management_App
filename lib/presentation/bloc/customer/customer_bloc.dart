import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/customer/add_customer.dart';
import '../../../domain/usecases/customer/delete_customer.dart';
import '../../../domain/usecases/customer/get_all_customers.dart';
import '../../../domain/usecases/customer/update_customer.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetAllCustomers getAllCustomers;
  final AddCustomer addCustomer;
  final UpdateCustomer updateCustomer;
  final DeleteCustomer deleteCustomer;

  CustomerBloc({
    required this.getAllCustomers,
    required this.addCustomer,
    required this.updateCustomer,
    required this.deleteCustomer,
  }) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomerEvent>(_onAddCustomer);
    on<UpdateCustomerEvent>(_onUpdateCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
    on<RefreshCustomers>(_onRefreshCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await getAllCustomers(const NoParams());
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) => emit(CustomerLoaded(customers)),
    );
  }

  Future<void> _onAddCustomer(
    AddCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await addCustomer(AddCustomerParams(
      name: event.name,
      phone: event.phone,
      address: event.address,
      defaultCommission: event.defaultCommission,
    ));

    await result.fold(
      (failure) async => emit(CustomerError(failure.message)),
      (_) async {
        emit(const CustomerOperationSuccess('Customer added successfully'));
        add(LoadCustomers());
      },
    );
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await updateCustomer(UpdateCustomerParams(
      id: event.id,
      name: event.name,
      phone: event.phone,
      address: event.address,
      defaultCommission: event.defaultCommission,
    ));

    await result.fold(
      (failure) async => emit(CustomerError(failure.message)),
      (_) async {
        emit(const CustomerOperationSuccess('Customer updated successfully'));
        add(LoadCustomers());
      },
    );
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    final result = await deleteCustomer(event.id);

    await result.fold(
      (failure) async => emit(CustomerError(failure.message)),
      (_) async {
        emit(const CustomerOperationSuccess('Customer deleted successfully'));
        add(LoadCustomers());
      },
    );
  }

  Future<void> _onRefreshCustomers(
    RefreshCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    add(LoadCustomers());
  }
}
