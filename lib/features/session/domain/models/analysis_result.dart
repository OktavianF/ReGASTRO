class AnalysisResult {
  final String feedbackMessage;
  final bool repCompleted;
  final bool isCompensating;
  final bool targetReached;
  final bool returnedToStart;
  final double progressPercentage;
  final double? thresholdLineY;
  final double? thresholdLineX;
  final String? secondaryFeedback;

  const AnalysisResult({
    required this.feedbackMessage,
    this.repCompleted = false,
    this.isCompensating = false,
    this.targetReached = false,
    this.returnedToStart = false,
    this.progressPercentage = 0.0,
    this.thresholdLineY,
    this.thresholdLineX,
    this.secondaryFeedback,
  });
}
