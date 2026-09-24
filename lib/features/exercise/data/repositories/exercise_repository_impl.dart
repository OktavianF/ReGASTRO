import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../models/exercise_model.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  // Mock data for Phase 3. Nantinya ini bisa dari Supabase atau SQLite.
  final List<ExerciseModel> _mockExercises = const [
    ExerciseModel(
      id: 'ex_001',
      title: 'Shoulder Flexion',
      description: 'Latihan untuk meningkatkan jangkauan gerak sendi bahu ke depan dan ke atas.',
      imageUrl: 'https://via.placeholder.com/150', // Ganti dengan aset lokal/icon nanti
      defaultRepetitions: 10,
      defaultSets: 3,
      instructions: [
        'Berdiri tegak atau duduk di kursi yang stabil.',
        'Posisikan lengan Anda lurus di samping tubuh.',
        'Perlahan angkat lengan Anda lurus ke depan dan terus ke atas sejauh mungkin tanpa rasa sakit.',
        'Tahan posisi selama 2-3 detik.',
        'Perlahan turunkan lengan kembali ke posisi awal.',
      ],
      targetRomMin: 90.0,
      targetRomMax: 180.0,
    ),
    // 7 latihan lainnya bisa ditambahkan nanti sesuai kesepakatan (hanya 1 template dulu)
  ];

  @override
  Future<Either<Failure, List<ExerciseEntity>>> getExercises() async {
    try {
      // Simulasi delay jaringan/loading
      await Future.delayed(const Duration(milliseconds: 500));
      return Right(_mockExercises);
    } catch (e) {
      return const Left(ServerFailure('Gagal mengambil data latihan'));
    }
  }

  @override
  Future<Either<Failure, ExerciseEntity>> getExerciseById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      final exercise = _mockExercises.firstWhere((element) => element.id == id);
      return Right(exercise);
    } catch (e) {
      return const Left(CacheFailure('Latihan tidak ditemukan'));
    }
  }
}
