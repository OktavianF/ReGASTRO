import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/landmark_utils.dart';
import '../models/analysis_result.dart';
import 'exercise_analyzer.dart';

class ElbowFlexionAnalyzer implements ExerciseAnalyzer {
  MovementState _state = MovementState.initial;
  bool _hasReachedTarget = false;
  double? _initialElbowY;

  @override
  void resetState() {
    _state = MovementState.initial;
    _hasReachedTarget = false;
    _initialElbowY = null;
  }

  @override
  AnalysisResult analyzePose(Pose pose) {
    final rightVis = LandmarkUtils.areLandmarksVisible(
      pose,
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    );
    final leftVis = LandmarkUtils.areLandmarksVisible(
      pose,
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    );

    if (!rightVis && !leftVis) {
      return const AnalysisResult(
        feedbackMessage: 'Posisikan tubuh menyamping ke kamera',
        progressPercentage: 0.0,
      );
    }

    final isRight = rightVis;
    final shoulderType = isRight ? PoseLandmarkType.rightShoulder : PoseLandmarkType.leftShoulder;
    final elbowType = isRight ? PoseLandmarkType.rightElbow : PoseLandmarkType.leftElbow;
    final wristType = isRight ? PoseLandmarkType.rightWrist : PoseLandmarkType.leftWrist;

    final shoulder = LandmarkUtils.getLandmark(pose, shoulderType)!;
    final elbow = LandmarkUtils.getLandmark(pose, elbowType)!;
    final wrist = LandmarkUtils.getLandmark(pose, wristType)!;

    _initialElbowY ??= elbow.y;

    final thresholdY = shoulder.y;
    final startY = elbow.y + (elbow.y - shoulder.y).abs();

    final totalDist = (startY - thresholdY).abs();
    final currentDist = (startY - wrist.y);
    double progress = totalDist > 0 ? (currentDist / totalDist) * 100 : 0;
    progress = progress.clamp(0.0, 100.0);

    // Compensation: Elbow instability (elbow moving up/down too much)
    final elbowMovement = (elbow.y - _initialElbowY!).abs();
    final isCompensating = elbowMovement > 35.0;

    bool repCompleted = false;
    String feedback = 'Tekuk siku membawa tangan ke atas';

    if (isCompensating) {
      feedback = 'Pertahankan posisi siku tetap stabil';
    }

    if (wrist.y <= thresholdY + 25) {
      _hasReachedTarget = true;
      _state = MovementState.targetReached;
      if (!isCompensating) {
        feedback = 'Siku tekuk sempurna! Luruskan kembali';
      }
    } else if (_hasReachedTarget) {
      _state = MovementState.returning;
      if (wrist.y >= startY - 30) {
        repCompleted = true;
        _hasReachedTarget = false;
        _state = MovementState.initial;
        feedback = 'Bagus! Repetisi selesai';
      } else {
        feedback = 'Luruskan siku ke posisi awal';
      }
    } else {
      _state = MovementState.movingToTarget;
      if (!isCompensating) {
        feedback = 'Tekuk siku hingga tangan mendekati bahu';
      }
    }

    return AnalysisResult(
      feedbackMessage: feedback,
      repCompleted: repCompleted,
      isCompensating: isCompensating,
      targetReached: _hasReachedTarget,
      returnedToStart: _state == MovementState.initial,
      progressPercentage: progress,
      thresholdLineY: thresholdY,
      secondaryFeedback: isCompensating ? 'Siku tidak stabil' : null,
    );
  }
}
