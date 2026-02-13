import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {}

class AddCustomerEvent extends CustomerEvent {
  final String name;
  final String? phone;
  final String? address;

  const AddCustomerEvent({
    required this.name,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [name, phone, address];
}

class UpdateCustomerEvent extends CustomerEvent {
  final String id;
  final String name;
  final String? phone;
  final String? address;

  const UpdateCustomerEvent({
    required this.id,
    required this.name,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [id, name, phone, address];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String id;

  const DeleteCustomerEvent(this.id);

  @override
  List<Object> get props => [id];
}

class RefreshCustomers extends CustomerEvent {}
