import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/landmark_utils.dart';
import '../models/analysis_result.dart';
import 'exercise_analyzer.dart';

class ForwardReachingAnalyzer implements ExerciseAnalyzer {
  MovementState _state = MovementState.initial;
  bool _hasReachedTarget = false;

  @override
  void resetState() {
    _state = MovementState.initial;
    _hasReachedTarget = false;
  }

  @override
  AnalysisResult analyzePose(Pose pose) {
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

    // Detect facing direction (facing right or facing left on screen)
    final isFacingRight = shoulder.x > hip.x || wrist.x > shoulder.x;

    // Vertical threshold X line: forward in front of shoulder
    final reachOffset = 180.0; // 180px reach forward
    final thresholdX = isFacingRight ? shoulder.x + reachOffset : shoulder.x - reachOffset;
    final startX = hip.x;

    final totalDist = (startX - thresholdX).abs();
    final currentDist = (startX - wrist.x).abs();
    double progress = totalDist > 0 ? (currentDist / totalDist) * 100 : 0;
    progress = progress.clamp(0.0, 100.0);

    // Trunk compensation check (leaning torso forward)
    final torsoLeaning = (shoulder.x - hip.x).abs();
    final isCompensating = torsoLeaning > 50.0;

    bool repCompleted = false;
    String feedback = 'Jangkaukan tangan lurus ke depan';

    if (isCompensating) {
      feedback = 'Pertahankan posisi badan tetap tegak';
    }

    final isPastThreshold = isFacingRight ? (wrist.x >= thresholdX) : (wrist.x <= thresholdX);

    if (isPastThreshold) {
      _hasReachedTarget = true;
      _state = MovementState.targetReached;
      if (!isCompensating) {
        feedback = 'Jangkauan target tercapai! Tarik tangan kembali';
      }
    } else if (_hasReachedTarget) {
      _state = MovementState.returning;
      final isReturned = isFacingRight ? (wrist.x <= startX + 40) : (wrist.x >= startX - 40);
      if (isReturned) {
        repCompleted = true;
        _hasReachedTarget = false;
        _state = MovementState.initial;
        feedback = 'Bagus! Repetisi selesai';
      } else {
        feedback = 'Kembalikan tangan ke dekat tubuh';
      }
    } else {
      _state = MovementState.movingToTarget;
      if (!isCompensating) {
        feedback = 'Jangkau sedikit lebih jauh melewati garis';
      }
    }

    return AnalysisResult(
      feedbackMessage: feedback,
      repCompleted: repCompleted,
      isCompensating: isCompensating,
      targetReached: _hasReachedTarget,
      returnedToStart: _state == MovementState.initial,
      progressPercentage: progress,
      thresholdLineX: thresholdX,
      secondaryFeedback: isCompensating ? 'Badan membungkuk ke depan' : null,
    );
  }
}
