import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final double? thresholdLineY;
  final double? thresholdLineX;
  final bool targetReached;

  PosePainter(
    this.poses,
    this.absoluteImageSize,
    this.rotation, {
    this.thresholdLineY,
    this.thresholdLineX,
    this.targetReached = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw threshold line if available
    if (thresholdLineY != null) {
      final lineY = translateY(thresholdLineY!, size, absoluteImageSize, rotation);
      final linePaint = Paint()
        ..color = targetReached ? Colors.greenAccent : Colors.cyanAccent
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(0, lineY),
        Offset(size.width, lineY),
        linePaint,
      );
    }

    if (thresholdLineX != null) {
      final lineX = translateX(thresholdLineX!, size, absoluteImageSize, rotation);
      final linePaint = Paint()
        ..color = targetReached ? Colors.greenAccent : Colors.cyanAccent
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(lineX, 0),
        Offset(lineX, size.height),
        linePaint,
      );
    }

    // 2. Draw Skeleton
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.greenAccent;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(
            translateX(landmark.x, size, absoluteImageSize, rotation),
            translateY(landmark.y, size, absoluteImageSize, rotation),
          ),
          5,
          paint,
        );
      });

      void paintLine(PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark? joint1 = pose.landmarks[type1];
        final PoseLandmark? joint2 = pose.landmarks[type2];
        if (joint1 == null || joint2 == null) return;

        canvas.drawLine(
          Offset(
            translateX(joint1.x, size, absoluteImageSize, rotation),
            translateY(joint1.y, size, absoluteImageSize, rotation),
          ),
          Offset(
            translateX(joint2.x, size, absoluteImageSize, rotation),
            translateY(joint2.y, size, absoluteImageSize, rotation),
          ),
          paintType,
        );
      }

      // Draw arms
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      // Draw Body
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, rightPaint);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, paint);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint);

      // Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses ||
        oldDelegate.thresholdLineY != thresholdLineY ||
        oldDelegate.thresholdLineX != thresholdLineX ||
        oldDelegate.targetReached != targetReached;
  }

  double translateX(double x, Size canvasSize, Size imageSize, InputImageRotation rotation) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x * canvasSize.width / imageSize.height;
      case InputImageRotation.rotation270deg:
        return canvasSize.width - x * canvasSize.width / imageSize.height;
      default:
        return x * canvasSize.width / imageSize.width;
    }
  }

  double translateY(double y, Size canvasSize, Size imageSize, InputImageRotation rotation) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y * canvasSize.height / imageSize.width;
      default:
        return y * canvasSize.height / imageSize.height;
    }
  }
}
