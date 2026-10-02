import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/landmark_utils.dart';
import '../models/analysis_result.dart';
import 'exercise_analyzer.dart';

class SitToStandAnalyzer implements ExerciseAnalyzer {
  MovementState _state = MovementState.initial;
  bool _hasReachedTarget = false;
  double? _sittingHipY;

  @override
  void resetState() {
    _state = MovementState.initial;
    _hasReachedTarget = false;
    _sittingHipY = null;
  }

  @override
  AnalysisResult analyzePose(Pose pose) {
    final rightVis = LandmarkUtils.areLandmarksVisible(
      pose,
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    );
    final leftVis = LandmarkUtils.areLandmarksVisible(
      pose,
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    );

    if (!rightVis && !leftVis) {
      return const AnalysisResult(
        feedbackMessage: 'Posisikan tubuh menyamping ke kamera (posisi duduk)',
        progressPercentage: 0.0,
      );
    }

    final isRight = rightVis;
    final shoulderType = isRight ? PoseLandmarkType.rightShoulder : PoseLandmarkType.leftShoulder;
    final hipType = isRight ? PoseLandmarkType.rightHip : PoseLandmarkType.leftHip;
    final shoulder = LandmarkUtils.getLandmark(pose, shoulderType)!;
    final hip = LandmarkUtils.getLandmark(pose, hipType)!;

    _sittingHipY ??= hip.y;

    // Threshold Y: standing hip height estimated using sitting shoulder level
    final thresholdY = shoulder.y + 20.0;
    final startY = _sittingHipY!;

    final totalDist = (startY - thresholdY).abs();
    final currentDist = (startY - hip.y);
    double progress = totalDist > 0 ? (currentDist / totalDist) * 100 : 0;
    progress = progress.clamp(0.0, 100.0);

    // Compensation: Excessive forward leaning during standing transition
    final torsoTilt = (shoulder.x - hip.x).abs();
    final isCompensating = torsoTilt > 60.0;

    bool repCompleted = false;
    String feedback = 'Berdiri tegak dari posisi duduk';

    if (isCompensating) {
      feedback = 'Pastikan posisi tubuh dan kaki tetap stabil saat berdiri';
    }

    if (hip.y <= thresholdY + 30) {
      _hasReachedTarget = true;
      _state = MovementState.targetReached;
      if (!isCompensating) {
        feedback = 'Posisi berdiri tegak tercapai! Duduk kembali';
      }
    } else if (_hasReachedTarget) {
      _state = MovementState.returning;
      if (hip.y >= startY - 30) {
        repCompleted = true;
        _hasReachedTarget = false;
        _state = MovementState.initial;
        feedback = 'Bagus! Repetisi selesai';
      } else {
        feedback = 'Duduk kembali dengan terkontrol';
      }
    } else {
      _state = MovementState.movingToTarget;
      if (!isCompensating) {
        feedback = 'Luruskan badan dan berdiri tegak';
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
      secondaryFeedback: isCompensating ? 'Keseimbangan tidak stabil' : null,
    );
  }
}
