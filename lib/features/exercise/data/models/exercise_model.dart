import '../../domain/entities/exercise_entity.dart';

class ExerciseModel extends ExerciseEntity {
  const ExerciseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.defaultRepetitions,
    required super.defaultSets,
    required super.instructions,
    required super.targetRomMin,
    required super.targetRomMax,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      defaultRepetitions: json['default_repetitions'] as int,
      defaultSets: json['default_sets'] as int,
      instructions: List<String>.from(json['instructions'] as List),
      targetRomMin: (json['target_rom_min'] as num).toDouble(),
      targetRomMax: (json['target_rom_max'] as num).toDouble(),
    );
  }
}
