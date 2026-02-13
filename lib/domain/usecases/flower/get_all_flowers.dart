import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/flower.dart';
import '../../repositories/flower_repository.dart';

class GetAllFlowers implements UseCase<List<Flower>, NoParams> {
  final FlowerRepository repository;

  GetAllFlowers(this.repository);

  @override
  Future<Either<Failure, List<Flower>>> call(NoParams params) async {
    return await repository.getAllFlowers();
  }
}
