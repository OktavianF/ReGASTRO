import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Helper class to extract landmarks based on MediaPipe index definitions.
class LandmarkUtils {
  
  /// Gets a specific landmark safely by its expected index.
  /// In ML Kit, PoseLandmarkType corresponds to MediaPipe 33-point topology.
  static PoseLandmark? getLandmark(Pose pose, PoseLandmarkType type) {
    return pose.landmarks[type];
  }

  /// Returns [x, y] coordinate array for the angle calculator.
  static List<double>? getCoordinate(Pose pose, PoseLandmarkType type) {
    final landmark = getLandmark(pose, type);
    if (landmark != null) {
      return [landmark.x, landmark.y];
    }
    return null;
  }

  /// Check if the required landmarks are visible and confident enough
  static bool areLandmarksVisible(Pose pose, List<PoseLandmarkType> requiredTypes, {double minConfidence = 0.5}) {
    for (final type in requiredTypes) {
      final landmark = pose.landmarks[type];
      if (landmark == null || landmark.likelihood < minConfidence) {
        return false;
      }
    }
    return true;
  }
}
