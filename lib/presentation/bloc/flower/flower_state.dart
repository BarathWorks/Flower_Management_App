import 'package:equatable/equatable.dart';
import '../../../domain/entities/flower.dart';

abstract class FlowerState extends Equatable {
  const FlowerState();

  @override
  List<Object> get props => [];
}

class FlowerInitial extends FlowerState {}

class FlowerLoading extends FlowerState {}

class FlowerLoaded extends FlowerState {
  final List<Flower> flowers;

  const FlowerLoaded(this.flowers);

  @override
  List<Object> get props => [flowers];
}

class FlowerError extends FlowerState {
  final String message;

  const FlowerError(this.message);

  @override
  List<Object> get props => [message];
}

class FlowerOperationSuccess extends FlowerState {
  final String message;

  const FlowerOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
