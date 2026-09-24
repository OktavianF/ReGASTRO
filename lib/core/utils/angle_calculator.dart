import 'dart:math' as math;

/// Utility class for calculating angles and biomechanical metrics from coordinates.
class AngleCalculator {
  /// Calculates the angle in degrees between three points.
  /// [p1] is the start point.
  /// [p2] is the middle point (the vertex/pivot).
  /// [p3] is the end point.
  ///
  /// Points should be provided as lists of [x, y] coordinates.
  static double getAngle(List<double> p1, List<double> p2, List<double> p3) {
    if (p1.length < 2 || p2.length < 2 || p3.length < 2) return 0.0;
    
    // Convert to radians
    double radians = math.atan2(p3[1] - p2[1], p3[0] - p2[0]) - 
                     math.atan2(p1[1] - p2[1], p1[0] - p2[0]);
    
    // Convert to degrees
    double angle = (radians * 180.0 / math.pi).abs();
    
    if (angle > 180.0) {
      angle = 360.0 - angle;
    }
    
    return angle;
  }

  /// Calculates the angle of a line segment with respect to the vertical axis.
  /// Useful for measuring trunk inclination.
  /// [p1] is the upper point (e.g. shoulder)
  /// [p2] is the lower point (e.g. hip)
  static double getVerticalInclination(List<double> p1, List<double> p2) {
    // A point vertically above p2
    List<double> verticalPoint = [p2[0], p2[1] - 100]; 
    return getAngle(p1, p2, verticalPoint);
  }
}
