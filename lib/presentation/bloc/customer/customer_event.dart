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
  final double? defaultCommission;
  final List<String> flowerIds;

  const AddCustomerEvent({
    required this.name,
    this.phone,
    this.address,
    this.defaultCommission,
    this.flowerIds = const [],
  });

  @override
  List<Object?> get props =>
      [name, phone, address, defaultCommission, flowerIds];
}

class UpdateCustomerEvent extends CustomerEvent {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final double? defaultCommission;
  final List<String> flowerIds;

  const UpdateCustomerEvent({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.defaultCommission,
    this.flowerIds = const [],
  });

  @override
  List<Object?> get props =>
      [id, name, phone, address, defaultCommission, flowerIds];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String id;

  const DeleteCustomerEvent(this.id);

  @override
  List<Object> get props => [id];
}

class RefreshCustomers extends CustomerEvent {}
