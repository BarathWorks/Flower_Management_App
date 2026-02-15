import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/settings_repository.dart';

class GetGlobalCommission implements UseCase<double?, NoParams> {
  final SettingsRepository repository;

  GetGlobalCommission(this.repository);

  @override
  Future<Either<Failure, double?>> call(NoParams params) async {
    return await repository.getGlobalCommission();
  }
}
