import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateGlobalCommission extends SettingsEvent {
  final double commission;

  const UpdateGlobalCommission(this.commission);

  @override
  List<Object?> get props => [commission];
}
