import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/angle_calculator.dart';

class SessionState {
  final int currentRepetition;
  final int currentSet;
  final double currentAngle;
  final bool isCompleted;
  final String feedbackMessage;

  const SessionState({
    this.currentRepetition = 0,
    this.currentSet = 1,
    this.currentAngle = 0.0,
    this.isCompleted = false,
    this.feedbackMessage = 'Bersiap...',
  });

  SessionState copyWith({
    int? currentRepetition,
    int? currentSet,
    double? currentAngle,
    bool? isCompleted,
    String? feedbackMessage,
  }) {
    return SessionState(
      currentRepetition: currentRepetition ?? this.currentRepetition,
      currentSet: currentSet ?? this.currentSet,
      currentAngle: currentAngle ?? this.currentAngle,
      isCompleted: isCompleted ?? this.isCompleted,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
    );
  }
}

class SessionController extends StateNotifier<SessionState> {
  final int targetRepetitions;
  final int targetSets;
  final double targetRomMin;
  final double targetRomMax;

  bool _isMovingUp = true;
  bool _repInProgress = false;

  SessionController({
    required this.targetRepetitions,
    required this.targetSets,
    required this.targetRomMin,
    required this.targetRomMax,
  }) : super(const SessionState());

  void processPose(Pose pose) {
    if (state.isCompleted) return;

    // Untuk Shoulder Flexion: Hitung sudut antara Hip, Shoulder, dan siku (atau pergelangan tangan).
    // Tapi karena lengan lurus, kita bisa ukur kemiringan lengan ke vertikal, 
    // atau sudut antara hip, shoulder, elbow.
    final shoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final elbow = pose.landmarks[PoseLandmarkType.rightElbow];
    final hip = pose.landmarks[PoseLandmarkType.rightHip];

    if (shoulder != null && elbow != null && hip != null &&
        shoulder.likelihood > 0.5 && elbow.likelihood > 0.5 && hip.likelihood > 0.5) {
      
      final angle = AngleCalculator.getAngle(
        [hip.x, hip.y],
        [shoulder.x, shoulder.y],
        [elbow.x, elbow.y],
      );

      _analyzeMovement(angle);
    }
  }

  void _analyzeMovement(double currentAngle) {
    String feedback = state.feedbackMessage;
    int reps = state.currentRepetition;
    int sets = state.currentSet;
    bool completed = false;

    // Logika State Machine sederhana untuk repetisi
    if (_isMovingUp) {
      if (currentAngle >= targetRomMax) {
        _isMovingUp = false;
        _repInProgress = true;
        feedback = 'Bagus! Sekarang turun perlahan.';
      } else {
        feedback = 'Angkat lengan Anda lebih tinggi...';
      }
    } else {
      if (currentAngle <= targetRomMin) {
        _isMovingUp = true;
        if (_repInProgress) {
          reps++;
          _repInProgress = false;
          
          if (reps >= targetRepetitions) {
            if (sets >= targetSets) {
              completed = true;
              feedback = 'Latihan Selesai! Hebat!';
            } else {
              sets++;
              reps = 0;
              feedback = 'Set $sets dimulai. Istirahat sejenak, lalu lanjut!';
            }
          } else {
            feedback = 'Repetisi $reps berhasil. Lanjut!';
          }
        }
      } else {
        feedback = 'Terus turunkan lengan...';
      }
    }

    state = state.copyWith(
      currentAngle: currentAngle,
      currentRepetition: reps,
      currentSet: sets,
      feedbackMessage: feedback,
      isCompleted: completed,
    );
  }
}

// Provider menggunakan Family untuk menerima parameter spesifik latihan
final sessionControllerProvider = StateNotifierProvider.family<SessionController, SessionState, Map<String, dynamic>>((ref, params) {
  return SessionController(
    targetRepetitions: params['reps'],
    targetSets: params['sets'],
    targetRomMin: params['romMin'],
    targetRomMax: params['romMax'],
  );
});
