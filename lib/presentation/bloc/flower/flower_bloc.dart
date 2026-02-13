import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/flower/add_flower.dart';
import '../../../domain/usecases/flower/delete_flower.dart';
import '../../../domain/usecases/flower/get_all_flowers.dart';
import 'flower_event.dart';
import 'flower_state.dart';

class FlowerBloc extends Bloc<FlowerEvent, FlowerState> {
  final GetAllFlowers getAllFlowers;
  final AddFlower addFlower;
  final DeleteFlower deleteFlower;

  FlowerBloc({
    required this.getAllFlowers,
    required this.addFlower,
    required this.deleteFlower,
  }) : super(FlowerInitial()) {
    on<LoadFlowers>(_onLoadFlowers);
    on<AddFlowerEvent>(_onAddFlower);
    on<DeleteFlowerEvent>(_onDeleteFlower);
    on<RefreshFlowers>(_onRefreshFlowers);
  }

  Future<void> _onLoadFlowers(
    LoadFlowers event,
    Emitter<FlowerState> emit,
  ) async {
    emit(FlowerLoading());
    final result = await getAllFlowers(const NoParams());
    result.fold(
      (failure) => emit(FlowerError(failure.message)),
      (flowers) => emit(FlowerLoaded(flowers)),
    );
  }

  Future<void> _onAddFlower(
    AddFlowerEvent event,
    Emitter<FlowerState> emit,
  ) async {
    emit(FlowerLoading());
    final result = await addFlower(event.name);

    await result.fold(
      (failure) async => emit(FlowerError(failure.message)),
      (_) async {
        emit(const FlowerOperationSuccess('Flower added successfully'));
        add(LoadFlowers());
      },
    );
  }

  Future<void> _onDeleteFlower(
    DeleteFlowerEvent event,
    Emitter<FlowerState> emit,
  ) async {
    final result = await deleteFlower(event.id);

    await result.fold(
      (failure) async => emit(FlowerError(failure.message)),
      (_) async {
        emit(const FlowerOperationSuccess('Flower deleted successfully'));
        add(LoadFlowers());
      },
    );
  }

  Future<void> _onRefreshFlowers(
    RefreshFlowers event,
    Emitter<FlowerState> emit,
  ) async {
    add(LoadFlowers());
  }
}
