import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/flower_repository.dart';

class AddFlower implements UseCase<void, String> {
  final FlowerRepository repository;

  AddFlower(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.addFlower(params);
  }
}
