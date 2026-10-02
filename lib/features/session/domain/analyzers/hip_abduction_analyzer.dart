import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/landmark_utils.dart';
import '../models/analysis_result.dart';
import 'exercise_analyzer.dart';

class HipAbductionAnalyzer implements ExerciseAnalyzer {
  MovementState _state = MovementState.initial;
  bool _hasReachedTarget = false;

  @override
  void resetState() {
    _state = MovementState.initial;
    _hasReachedTarget = false;
  }

  @override
  AnalysisResult analyzePose(Pose pose) {
    final frontalVis = LandmarkUtils.areLandmarksVisible(
      pose,
      [
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.leftAnkle,
        PoseLandmarkType.rightAnkle,
      ],
    );

    if (!frontalVis) {
      return const AnalysisResult(
        feedbackMessage: 'Posisikan tubuh menghadap kamera (posisi berdiri)',
        progressPercentage: 0.0,
      );
    }

    final leftShoulder = LandmarkUtils.getLandmark(pose, PoseLandmarkType.leftShoulder)!;
    final rightShoulder = LandmarkUtils.getLandmark(pose, PoseLandmarkType.rightShoulder)!;
    final leftKnee = LandmarkUtils.getLandmark(pose, PoseLandmarkType.leftKnee)!;
    final rightKnee = LandmarkUtils.getLandmark(pose, PoseLandmarkType.rightKnee)!;
    final leftAnkle = LandmarkUtils.getLandmark(pose, PoseLandmarkType.leftAnkle)!;
    final rightAnkle = LandmarkUtils.getLandmark(pose, PoseLandmarkType.rightAnkle)!;

    // Pick active leg (ankle that moves highest / lowest y)
    final isLeftActive = leftAnkle.y < rightAnkle.y;
    final activeAnkle = isLeftActive ? leftAnkle : rightAnkle;
    final activeKnee = isLeftActive ? leftKnee : rightKnee;

    // Threshold line: Horizontal line right below knee
    final thresholdY = activeKnee.y + 30.0;
    final startY = activeAnkle.y;

    final totalDist = (startY - thresholdY).abs();
    final currentDist = (startY - activeAnkle.y);
    double progress = totalDist > 0 ? (currentDist / totalDist) * 100 : 0;
    progress = progress.clamp(0.0, 100.0);

    // Trunk compensation (shoulder tilt)
    final shoulderTilt = (leftShoulder.y - rightShoulder.y).abs();
    final isCompensating = shoulderTilt > 30.0;

    bool repCompleted = false;
    String feedback = 'Gerakkan tungkai ke arah samping';

    if (isCompensating) {
      feedback = 'Pertahankan badan tetap tegak, jangan miring';
    }

    if (activeAnkle.y <= thresholdY) {
      _hasReachedTarget = true;
      _state = MovementState.targetReached;
      if (!isCompensating) {
        feedback = 'Target samping tercapai! Kembalikan kaki';
      }
    } else if (_hasReachedTarget) {
      _state = MovementState.returning;
      if (activeAnkle.y >= startY - 25) {
        repCompleted = true;
        _hasReachedTarget = false;
        _state = MovementState.initial;
        feedback = 'Bagus! Repetisi selesai';
      } else {
        feedback = 'Kembalikan tungkai ke posisi rapat';
      }
    } else {
      _state = MovementState.movingToTarget;
      if (!isCompensating) {
        feedback = 'Angkat tungkai ke samping mendekati garis batas di bawah lutut';
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
      secondaryFeedback: isCompensating ? 'Badan miring saat mengangkat kaki' : null,
    );
  }
}
