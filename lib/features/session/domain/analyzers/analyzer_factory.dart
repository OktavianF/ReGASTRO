import 'exercise_analyzer.dart';
import 'shoulder_flexion_analyzer.dart';
import 'elbow_flexion_analyzer.dart';
import 'shoulder_abduction_analyzer.dart';
import 'forward_reaching_analyzer.dart';
import 'knee_extension_analyzer.dart';
import 'hip_abduction_analyzer.dart';
import 'sit_to_stand_analyzer.dart';
import 'trunk_rotation_analyzer.dart';

class AnalyzerFactory {
  static ExerciseAnalyzer createAnalyzer(String exerciseType) {
    switch (exerciseType) {
      case 'shoulder_flexion':
        return ShoulderFlexionAnalyzer();
      case 'elbow_flexion_extension':
        return ElbowFlexionAnalyzer();
      case 'shoulder_abduction':
        return ShoulderAbductionAnalyzer();
      case 'forward_reaching':
        return ForwardReachingAnalyzer();
      case 'knee_extension':
        return KneeExtensionAnalyzer();
      case 'hip_abduction':
        return HipAbductionAnalyzer();
      case 'sit_to_stand':
        return SitToStandAnalyzer();
      case 'trunk_rotation':
        return TrunkRotationAnalyzer();
      default:
        return ShoulderFlexionAnalyzer();
    }
  }
}
