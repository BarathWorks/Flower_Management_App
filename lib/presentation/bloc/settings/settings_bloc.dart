import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/settings/get_global_commission.dart';
import '../../../domain/usecases/settings/set_global_commission.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetGlobalCommission getGlobalCommission;
  final SetGlobalCommission setGlobalCommission;

  SettingsBloc({
    required this.getGlobalCommission,
    required this.setGlobalCommission,
  }) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateGlobalCommission>(_onUpdateGlobalCommission);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    final result = await getGlobalCommission(const NoParams());

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (commission) => emit(SettingsLoaded(globalCommission: commission)),
    );
  }

  Future<void> _onUpdateGlobalCommission(
    UpdateGlobalCommission event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    final result = await setGlobalCommission(event.commission);

    await result.fold(
      (failure) async => emit(SettingsError(failure.message)),
      (_) async {
        // Reload settings to confirm update
        add(LoadSettings());
      },
    );
  }
}
