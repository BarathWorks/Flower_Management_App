import 'package:equatable/equatable.dart';

abstract class FlowerEvent extends Equatable {
  const FlowerEvent();

  @override
  List<Object> get props => [];
}

class LoadFlowers extends FlowerEvent {}

class AddFlowerEvent extends FlowerEvent {
  final String name;

  const AddFlowerEvent(this.name);

  @override
  List<Object> get props => [name];
}

class DeleteFlowerEvent extends FlowerEvent {
  final String id;

  const DeleteFlowerEvent(this.id);

  @override
  List<Object> get props => [id];
}

class RefreshFlowers extends FlowerEvent {}
