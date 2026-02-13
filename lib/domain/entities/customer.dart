import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, phone, address, createdAt];
}
