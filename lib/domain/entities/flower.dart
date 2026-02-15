import 'package:equatable/equatable.dart';

class Flower extends Equatable {
  final String id;
  final String name;
  final double? defaultRate;
  final DateTime createdAt;

  const Flower({
    required this.id,
    required this.name,
    this.defaultRate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, defaultRate, createdAt];
}
