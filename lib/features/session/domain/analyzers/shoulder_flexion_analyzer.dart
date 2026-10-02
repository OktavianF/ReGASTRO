import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/landmark_utils.dart';
import '../models/analysis_result.dart';
import 'exercise_analyzer.dart';

class ShoulderFlexionAnalyzer implements ExerciseAnalyzer {
  MovementState _state = MovementState.initial;
  bool _hasReachedTarget = false;

  @override
  void resetState() {
    _state = MovementState.initial;
    _hasReachedTarget = false;
  }

  @override
  AnalysisResult analyzePose(Pose pose) {
    // Determine active side (right or left) based on visibility
    final rightVis = LandmarkUtils.areLandmarksVisible(
      pose,
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightWrist, PoseLandmarkType.rightHip],
    );
    final leftVis = LandmarkUtils.areLandmarksVisible(
      pose,
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftWrist, PoseLandmarkType.leftHip],
    );

    if (!rightVis && !leftVis) {
      return const AnalysisResult(
        feedbackMessage: 'Posisikan tubuh menyamping ke kamera',
        progressPercentage: 0.0,
      );
    }

    final isRight = rightVis;
    final shoulderType = isRight ? PoseLandmarkType.rightShoulder : PoseLandmarkType.leftShoulder;
    final wristType = isRight ? PoseLandmarkType.rightWrist : PoseLandmarkType.leftWrist;
    final hipType = isRight ? PoseLandmarkType.rightHip : PoseLandmarkType.leftHip;

    final shoulder = LandmarkUtils.getLandmark(pose, shoulderType)!;
    final wrist = LandmarkUtils.getLandmark(pose, wristType)!;
    final hip = LandmarkUtils.getLandmark(pose, hipType)!;

    // Threshold Y: Horizontal line at shoulder height
    final thresholdY = shoulder.y;
    final startY = hip.y;

    // Progress percentage
    final totalDist = (startY - thresholdY).abs();
    final currentDist = (startY - wrist.y);
    double progress = totalDist > 0 ? (currentDist / totalDist) * 100 : 0;
    progress = progress.clamp(0.0, 100.0);

    // Trunk compensation check (leaning forward/backward)
    final trunkOffset = (shoulder.x - hip.x).abs();
    final isCompensating = trunkOffset > 40.0; // 40px threshold

    bool repCompleted = false;
    String feedback = 'Angkat lengan lurus ke atas';

    if (isCompensating) {
      feedback = 'Pertahankan badan tetap tegak';
    }

    // State machine logic
    if (wrist.y < thresholdY) {
      // Reached or surpassed shoulder height
      _hasReachedTarget = true;
      _state = MovementState.targetReached;
      if (!isCompensating) {
        feedback = 'Target tercapai! Turunkan perlahan';
      }
    } else if (_hasReachedTarget) {
      // Returning back down
      _state = MovementState.returning;
      if (wrist.y >= startY - 30) {
        // Returned to starting position
        repCompleted = true;
        _hasReachedTarget = false;
        _state = MovementState.initial;
        feedback = 'Bagus! Repetisi selesai';
      } else {
        feedback = 'Kembalikan lengan ke posisi awal';
      }
    } else {
      // Moving up
      _state = MovementState.movingToTarget;
      if (!isCompensating) {
        feedback = 'Angkat lengan melewati garis bahu';
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
      secondaryFeedback: isCompensating ? 'Kompensasi badan terdeteksi' : null,
    );
  }
}
