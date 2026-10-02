import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../../core/utils/landmark_utils.dart';
import '../models/analysis_result.dart';
import 'exercise_analyzer.dart';

class TrunkRotationAnalyzer implements ExerciseAnalyzer {
  MovementState _state = MovementState.initial;
  bool _hasReachedRight = false;
  bool _hasReachedLeft = false;
  double? _initialMidX;

  @override
  void resetState() {
    _state = MovementState.initial;
    _hasReachedRight = false;
    _hasReachedLeft = false;
    _initialMidX = null;
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
        feedbackMessage: 'Posisikan tubuh menghadap kamera (posisi duduk)',
        progressPercentage: 0.0,
      );
    }

    final leftShoulder = LandmarkUtils.getLandmark(pose, PoseLandmarkType.leftShoulder)!;
    final rightShoulder = LandmarkUtils.getLandmark(pose, PoseLandmarkType.rightShoulder)!;
    final leftHip = LandmarkUtils.getLandmark(pose, PoseLandmarkType.leftHip)!;
    final rightHip = LandmarkUtils.getLandmark(pose, PoseLandmarkType.rightHip)!;

    final currentMidX = (leftShoulder.x + rightShoulder.x) / 2.0;
    _initialMidX ??= currentMidX;

    final rotationOffset = 60.0; // 60px shift
    final rightThresholdX = _initialMidX! + rotationOffset;
    final leftThresholdX = _initialMidX! - rotationOffset;

    final distFromCenter = (currentMidX - _initialMidX!).abs();
    double progress = (distFromCenter / rotationOffset) * 100;
    progress = progress.clamp(0.0, 100.0);

    // Compensation: Hip/Pelvis moving too much
    final hipMidX = (leftHip.x + rightHip.x) / 2.0;
    final hipShift = (hipMidX - _initialMidX!).abs();
    final isCompensating = hipShift > 35.0;

    bool repCompleted = false;
    String feedback = 'Putar badan ke kanan atau ke kiri';

    if (isCompensating) {
      feedback = 'Pertahankan posisi panggul agar tidak ikut berputar';
    }

    if (currentMidX >= rightThresholdX) {
      _hasReachedRight = true;
      feedback = 'Bagus! Kembali ke tengah, lalu ke arah sebaliknya';
    } else if (currentMidX <= leftThresholdX) {
      _hasReachedLeft = true;
      feedback = 'Bagus! Kembali ke tengah, lalu ke arah sebaliknya';
    }

    if ((_hasReachedRight || _hasReachedLeft) && distFromCenter < 20.0) {
      repCompleted = true;
      _hasReachedRight = false;
      _hasReachedLeft = false;
      _state = MovementState.initial;
      feedback = 'Bagus! Repetisi selesai';
    }

    return AnalysisResult(
      feedbackMessage: feedback,
      repCompleted: repCompleted,
      isCompensating: isCompensating,
      targetReached: _hasReachedRight || _hasReachedLeft,
      returnedToStart: _state == MovementState.initial,
      progressPercentage: progress,
      thresholdLineX: _hasReachedRight ? leftThresholdX : rightThresholdX,
      secondaryFeedback: isCompensating ? 'Pinggul ikut bergeser' : null,
    );
  }
}
