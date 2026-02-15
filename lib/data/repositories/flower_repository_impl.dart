import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/flower.dart';
import '../../domain/repositories/flower_repository.dart';
import '../datasources/flower_remote_datasource.dart';

class FlowerRepositoryImpl implements FlowerRepository {
  final FlowerRemoteDataSource remoteDataSource;

  FlowerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Flower>>> getAllFlowers() async {
    try {
      final flowers = await remoteDataSource.getAllFlowers();
      return Right(flowers);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFlower(
      String name, double? defaultRate) async {
    try {
      await remoteDataSource.addFlower(name, defaultRate);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFlower(String id) async {
    try {
      await remoteDataSource.deleteFlower(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
