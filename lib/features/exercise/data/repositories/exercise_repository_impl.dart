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
      exerciseType: 'shoulder_flexion',
      imageUrl: 'https://via.placeholder.com/150',
      defaultRepetitions: 10,
      defaultSets: 2,
      restSeconds: 30,
      cameraOrientation: 'sagittal',
      instructions: [
        'Duduk tegak, posisikan HP di samping tubuh (menyamping).',
        'Posisikan lengan lurus di samping tubuh.',
        'Angkat lengan lurus ke depan dan ke atas hingga melewati garis bahu.',
        'Kembalikan lengan perlahan ke posisi awal.',
      ],
    ),
    ExerciseModel(
      id: 'ex_002',
      title: 'Elbow Flexion–Extension',
      description: 'Latihan untuk melatih kelenturan dan kekuatan sendi siku.',
      exerciseType: 'elbow_flexion_extension',
      imageUrl: 'https://via.placeholder.com/150',
      defaultRepetitions: 10,
      defaultSets: 2,
      restSeconds: 30,
      cameraOrientation: 'sagittal',
      instructions: [
        'Duduk tegak, posisikan HP di samping tubuh (menyamping).',
        'Pertahankan posisi siku tetap stabil di samping dada.',
        'Tekuk siku hingga telapak tangan mendekati bahu melewati garis batas.',
        'Luruskan siku kembali ke posisi awal.',
      ],
    ),
    ExerciseModel(
      id: 'ex_003',
      title: 'Shoulder Abduction',
      description: 'Latihan merentangkan lengan ke samping tubuh.',
      exerciseType: 'shoulder_abduction',
      imageUrl: 'https://via.placeholder.com/150',
      defaultRepetitions: 10,
      defaultSets: 2,
      restSeconds: 30,
      cameraOrientation: 'frontal',
      instructions: [
        'Duduk tegak menghadap kamera HP.',
        'Posisikan lengan di samping badan.',
        'Angkat lengan ke arah samping hingga menyentuh garis batas setinggi bahu.',
        'Turunkan kembali lengan ke posisi awal.',
      ],
    ),
    ExerciseModel(
      id: 'ex_004',
      title: 'Forward Reaching',
      description: 'Latihan menjangkau lengan lurus ke depan.',
      exerciseType: 'forward_reaching',
      imageUrl: 'https://via.placeholder.com/150',
      defaultRepetitions: 10,
      defaultSets: 2,
      restSeconds: 30,
      cameraOrientation: 'sagittal',
      instructions: [
        'Duduk tegak, posisikan HP di samping tubuh (menyamping).',
        'Jangkaukan tangan lurus ke depan hingga melewati garis batas vertikal.',
        'Pertahankan posisi badan agar tidak terlalu membungkuk.',
        'Tarik kembali tangan ke dekat tubuh.',
      ],
    ),
    ExerciseModel(
      id: 'ex_005',
      title: 'Knee Extension',
      description: 'Latihan meluruskan sendi lutut saat duduk.',
      exerciseType: 'knee_extension',
      imageUrl: 'https://via.placeholder.com/150',
      defaultRepetitions: 10,
      defaultSets: 2,
      restSeconds: 30,
      cameraOrientation: 'sagittal',
      instructions: [
        'Duduk di kursi stabil dengan paha disangga, HP di samping tubuh.',
        'Angkat dan luruskan tungkai bawah hingga pergelangan kaki mendekati garis lutut.',
        'Pertahankan paha tetap menempel di kursi.',
        'Turunkan kembali kaki ke posisi semula.',
      ],
    ),
    ExerciseModel(
      id: 'ex_006',
      title: 'Hip Abduction',
      description: 'Latihan menggerakkan kaki ke arah samping saat berdiri.',
      exerciseType: 'hip_abduction',
      imageUrl: 'https://via.placeholder.com/150',
      defaultRepetitions: 10,
      defaultSets: 2,
      restSeconds: 45,
      cameraOrientation: 'frontal',
      instructions: [
        'Berdiri tegak menghadap kamera HP sambil berpegangan pada kursi/meja.',
        'Gerakkan tungkai ke arah samping hingga pergelangan kaki melewati garis batas horizontal di bawah knee.',
        'Jaga agar badan tidak miring ke samping.',
        'Kembalikan tungkai ke posisi rapat.',
      ],
    ),
    ExerciseModel(
      id: 'ex_007',
      title: 'Sit-to-Stand',
      description: 'Latihan transisi dari posisi duduk ke posisi berdiri tegak.',
      exerciseType: 'sit_to_stand',
      imageUrl: 'https://via.placeholder.com/150',
      defaultRepetitions: 8,
      defaultSets: 2,
      restSeconds: 60,
      cameraOrientation: 'sagittal',
      instructions: [
        'Duduk di kursi, posisikan HP di samping tubuh (menyamping).',
        'Berdiri tegak hingga pinggul melewati garis batas berdiri.',
        'Pertahankan keseimbangan badan.',
        'Duduk kembali dengan terkontrol ke posisi awal.',
      ],
    ),
    ExerciseModel(
      id: 'ex_008',
      title: 'Trunk Rotation',
      description: 'Latihan memutar/memindahkan tumpuan badan ke kanan dan kiri.',
      exerciseType: 'trunk_rotation',
      imageUrl: 'https://via.placeholder.com/150',
      defaultRepetitions: 10,
      defaultSets: 2,
      restSeconds: 30,
      cameraOrientation: 'frontal',
      instructions: [
        'Duduk tegak menghadap kamera HP.',
        'Putar/gerakkan badan ke kanan hingga bahu melewati garis batas kanan.',
        'Kembali ke tengah, lalu putar ke kiri melewati garis batas kiri.',
        'Jaga agar panggul tetap menempel di kursi.',
      ],
    ),
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
