import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/landmark_utils.dart';
import '../models/analysis_result.dart';
import 'exercise_analyzer.dart';

class KneeExtensionAnalyzer implements ExerciseAnalyzer {
  MovementState _state = MovementState.initial;
  bool _hasReachedTarget = false;
  double? _initialHipY;

  @override
  void resetState() {
    _state = MovementState.initial;
    _hasReachedTarget = false;
    _initialHipY = null;
  }

  @override
  AnalysisResult analyzePose(Pose pose) {
    final rightVis = LandmarkUtils.areLandmarksVisible(
      pose,
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    );
    final leftVis = LandmarkUtils.areLandmarksVisible(
      pose,
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    );

    if (!rightVis && !leftVis) {
      return const AnalysisResult(
        feedbackMessage: 'Posisikan tubuh menyamping ke kamera (posisi duduk)',
        progressPercentage: 0.0,
      );
    }

    final isRight = rightVis;
    final hipType = isRight ? PoseLandmarkType.rightHip : PoseLandmarkType.leftHip;
    final kneeType = isRight ? PoseLandmarkType.rightKnee : PoseLandmarkType.leftKnee;
    final ankleType = isRight ? PoseLandmarkType.rightAnkle : PoseLandmarkType.leftAnkle;

    final hip = LandmarkUtils.getLandmark(pose, hipType)!;
    final knee = LandmarkUtils.getLandmark(pose, kneeType)!;
    final ankle = LandmarkUtils.getLandmark(pose, ankleType)!;

    _initialHipY ??= hip.y;

    final thresholdY = knee.y;
    final startY = knee.y + (knee.y - hip.y).abs(); // Ankle hanging down

    final totalDist = (startY - thresholdY).abs();
    final currentDist = (startY - ankle.y);
    double progress = totalDist > 0 ? (currentDist / totalDist) * 100 : 0;
    progress = progress.clamp(0.0, 100.0);

    // Compensation: Hip lifting off chair
    final hipMovement = (hip.y - _initialHipY!).abs();
    final isCompensating = hipMovement > 30.0;

    bool repCompleted = false;
    String feedback = 'Luruskan lutut ke depan';

    if (isCompensating) {
      feedback = 'Pertahankan paha tetap menempel di kursi';
    }

    if (ankle.y <= thresholdY + 30) {
      _hasReachedTarget = true;
      _state = MovementState.targetReached;
      if (!isCompensating) {
        feedback = 'Lutut lurus sempurna! Turunkan perlahan';
      }
    } else if (_hasReachedTarget) {
      _state = MovementState.returning;
      if (ankle.y >= startY - 30) {
        repCompleted = true;
        _hasReachedTarget = false;
        _state = MovementState.initial;
        feedback = 'Bagus! Repetisi selesai';
      } else {
        feedback = 'Turunkan kaki ke posisi semula';
      }
    } else {
      _state = MovementState.movingToTarget;
      if (!isCompensating) {
        feedback = 'Luruskan lutut hingga pergelangan kaki naik setinggi lutut';
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
      secondaryFeedback: isCompensating ? 'Paha terangkat dari kursi' : null,
    );
  }
}
