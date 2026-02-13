import 'package:equatable/equatable.dart';

class Flower extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;

  const Flower({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, name, createdAt];
}
