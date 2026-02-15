import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/flower_repository.dart';

class AddFlowerParams {
  final String name;
  final double? defaultRate;

  AddFlowerParams({required this.name, this.defaultRate});
}

class AddFlower implements UseCase<void, AddFlowerParams> {
  final FlowerRepository repository;

  AddFlower(this.repository);

  @override
  Future<Either<Failure, void>> call(AddFlowerParams params) async {
    return await repository.addFlower(params.name, params.defaultRate);
  }
}
