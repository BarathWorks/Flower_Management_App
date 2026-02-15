import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final double? defaultCommission;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.defaultCommission,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, name, phone, address, defaultCommission, createdAt];
}
