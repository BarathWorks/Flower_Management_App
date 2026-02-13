import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/flower.dart';

abstract class FlowerRepository {
  Future<Either<Failure, List<Flower>>> getAllFlowers();
  Future<Either<Failure, void>> addFlower(String name);
  Future<Either<Failure, void>> deleteFlower(String id);
}
