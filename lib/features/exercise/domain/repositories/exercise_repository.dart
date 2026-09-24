import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/exercise_entity.dart';

abstract class ExerciseRepository {
  Future<Either<Failure, List<ExerciseEntity>>> getExercises();
  Future<Either<Failure, ExerciseEntity>> getExerciseById(String id);
}
