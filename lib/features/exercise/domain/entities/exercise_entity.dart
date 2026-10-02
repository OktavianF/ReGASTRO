import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String exerciseType;
  final String imageUrl;
  final int defaultRepetitions;
  final int defaultSets;
  final int restSeconds;
  final String cameraOrientation; // 'sagittal' or 'frontal'
  final List<String> instructions;

  const ExerciseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.exerciseType,
    required this.imageUrl,
    required this.defaultRepetitions,
    required this.defaultSets,
    required this.restSeconds,
    required this.cameraOrientation,
    required this.instructions,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        exerciseType,
        imageUrl,
        defaultRepetitions,
        defaultSets,
        restSeconds,
        cameraOrientation,
        instructions,
      ];
}

