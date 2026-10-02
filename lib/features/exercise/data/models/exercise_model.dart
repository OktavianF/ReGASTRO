import '../../domain/entities/exercise_entity.dart';

class ExerciseModel extends ExerciseEntity {
  const ExerciseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.exerciseType,
    required super.imageUrl,
    required super.defaultRepetitions,
    required super.defaultSets,
    required super.restSeconds,
    required super.cameraOrientation,
    required super.instructions,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      exerciseType: json['exercise_type'] as String? ?? 'shoulder_flexion',
      imageUrl: json['image_url'] as String,
      defaultRepetitions: json['default_repetitions'] as int,
      defaultSets: json['default_sets'] as int,
      restSeconds: json['rest_seconds'] as int? ?? 30,
      cameraOrientation: json['camera_orientation'] as String? ?? 'sagittal',
      instructions: List<String>.from(json['instructions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'exercise_type': exerciseType,
      'image_url': imageUrl,
      'default_repetitions': defaultRepetitions,
      'default_sets': defaultSets,
      'rest_seconds': restSeconds,
      'camera_orientation': cameraOrientation,
      'instructions': instructions,
    };
  }
}

