import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, double?>> getGlobalCommission();
  Future<Either<Failure, void>> setGlobalCommission(double commission);
}
