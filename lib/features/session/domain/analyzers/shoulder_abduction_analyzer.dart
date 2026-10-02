import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/landmark_utils.dart';
import '../models/analysis_result.dart';
import 'exercise_analyzer.dart';

class ShoulderAbductionAnalyzer implements ExerciseAnalyzer {
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
        PoseLandmarkType.leftHip,
        PoseLandmarkType.rightHip,
      ],
    );

    if (!frontalVis) {
      return const AnalysisResult(
        feedbackMessage: 'Posisikan tubuh menghadap kamera',
        progressPercentage: 0.0,
      );
    }

    final leftShoulder = LandmarkUtils.getLandmark(pose, PoseLandmarkType.leftShoulder)!;
    final rightShoulder = LandmarkUtils.getLandmark(pose, PoseLandmarkType.rightShoulder)!;
    final leftHip = LandmarkUtils.getLandmark(pose, PoseLandmarkType.leftHip)!;
    final rightHip = LandmarkUtils.getLandmark(pose, PoseLandmarkType.rightHip)!;

    final leftWrist = LandmarkUtils.getLandmark(pose, PoseLandmarkType.leftWrist);
    final rightWrist = LandmarkUtils.getLandmark(pose, PoseLandmarkType.rightWrist);

    // Pick active arm (highest wrist position / lower y)
    PoseLandmark activeWrist;
    PoseLandmark activeShoulder;
    PoseLandmark activeHip;

    if (leftWrist != null && rightWrist != null) {
      if (leftWrist.y < rightWrist.y) {
        activeWrist = leftWrist;
        activeShoulder = leftShoulder;
        activeHip = leftHip;
      } else {
        activeWrist = rightWrist;
        activeShoulder = rightShoulder;
        activeHip = rightHip;
      }
    } else if (leftWrist != null) {
      activeWrist = leftWrist;
      activeShoulder = leftShoulder;
      activeHip = leftHip;
    } else if (rightWrist != null) {
      activeWrist = rightWrist;
      activeShoulder = rightShoulder;
      activeHip = rightHip;
    } else {
      return const AnalysisResult(
        feedbackMessage: 'Pastikan pergelangan tangan terlihat di kamera',
        progressPercentage: 0.0,
      );
    }

    final thresholdY = activeShoulder.y;
    final startY = activeHip.y;

    final totalDist = (startY - thresholdY).abs();
    final currentDist = (startY - activeWrist.y);
    double progress = totalDist > 0 ? (currentDist / totalDist) * 100 : 0;
    progress = progress.clamp(0.0, 100.0);

    // Lateral flexion compensation (shoulder tilt)
    final shoulderTilt = (leftShoulder.y - rightShoulder.y).abs();
    final isCompensating = shoulderTilt > 30.0;

    bool repCompleted = false;
    String feedback = 'Angkat lengan ke arah samping';

    if (isCompensating) {
      feedback = 'Pertahankan badan tetap tegak, jangan miring';
    }

    if (activeWrist.y <= thresholdY + 20) {
      _hasReachedTarget = true;
      _state = MovementState.targetReached;
      if (!isCompensating) {
        feedback = 'Target samping tercapai! Turunkan perlahan';
      }
    } else if (_hasReachedTarget) {
      _state = MovementState.returning;
      if (activeWrist.y >= startY - 30) {
        repCompleted = true;
        _hasReachedTarget = false;
        _state = MovementState.initial;
        feedback = 'Bagus! Repetisi selesai';
      } else {
        feedback = 'Kembalikan lengan ke samping tubuh';
      }
    } else {
      _state = MovementState.movingToTarget;
      if (!isCompensating) {
        feedback = 'Rentangkan lengan ke samping setinggi bahu';
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
      secondaryFeedback: isCompensating ? 'Badan miring ke samping' : null,
    );
  }
}
