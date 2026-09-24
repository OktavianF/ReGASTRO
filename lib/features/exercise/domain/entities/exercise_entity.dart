import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl; // Can be a local asset path or network URL
  final int defaultRepetitions;
  final int defaultSets;
  final List<String> instructions;
  final double targetRomMin; // Target Range of Motion Min
  final double targetRomMax; // Target Range of Motion Max

  const ExerciseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.defaultRepetitions,
    required this.defaultSets,
    required this.instructions,
    required this.targetRomMin,
    required this.targetRomMax,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        defaultRepetitions,
        defaultSets,
        instructions,
        targetRomMin,
        targetRomMax,
      ];
}
