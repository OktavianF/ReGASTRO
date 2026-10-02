import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/analysis_result.dart';

enum MovementState {
  initial,
  movingToTarget,
  targetReached,
  returning,
}

abstract class ExerciseAnalyzer {
  AnalysisResult analyzePose(Pose pose);
  void resetState();
}
