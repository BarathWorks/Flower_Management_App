import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/flower_repository.dart';

class DeleteFlower implements UseCase<void, String> {
  final FlowerRepository repository;

  DeleteFlower(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteFlower(params);
  }
}
