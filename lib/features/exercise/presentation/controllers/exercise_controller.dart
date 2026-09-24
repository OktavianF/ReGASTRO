import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/exercise_repository_impl.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl();
});

class ExerciseState {
  final List<ExerciseEntity> exercises;
  final bool isLoading;
  final String? errorMessage;

  const ExerciseState({
    this.exercises = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ExerciseState copyWith({
    List<ExerciseEntity>? exercises,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ExerciseState(
      exercises: exercises ?? this.exercises,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ExerciseController extends StateNotifier<ExerciseState> {
  final ExerciseRepository _repository;

  ExerciseController(this._repository) : super(const ExerciseState()) {
    loadExercises();
  }

  Future<void> loadExercises() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getExercises();
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (exercises) => state = state.copyWith(isLoading: false, exercises: exercises),
    );
  }
}

final exerciseControllerProvider = StateNotifierProvider<ExerciseController, ExerciseState>((ref) {
  return ExerciseController(ref.watch(exerciseRepositoryProvider));
});
