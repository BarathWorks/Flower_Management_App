import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/settings_repository.dart';

class SetGlobalCommission implements UseCase<void, double> {
  final SettingsRepository repository;

  SetGlobalCommission(this.repository);

  @override
  Future<Either<Failure, void>> call(double commission) async {
    return await repository.setGlobalCommission(commission);
  }
}
