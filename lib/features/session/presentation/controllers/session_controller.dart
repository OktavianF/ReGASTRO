import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../domain/analyzers/analyzer_factory.dart';
import '../../domain/analyzers/exercise_analyzer.dart';

class SessionState {
  final int currentRepetition;
  final int currentSet;
  final double progressPercentage;
  final int elapsedSeconds;
  final bool isCompleted;
  final String feedbackMessage;
  final String? secondaryFeedback;
  final int trunkCompensationCount;
  final int incompleteReachCount;
  final int notReturnedCount;
  final double? thresholdLineY;
  final double? thresholdLineX;

  const SessionState({
    this.currentRepetition = 0,
    this.currentSet = 1,
    this.progressPercentage = 0.0,
    this.elapsedSeconds = 0,
    this.isCompleted = false,
    this.feedbackMessage = 'Bersiap...',
    this.secondaryFeedback,
    this.trunkCompensationCount = 0,
    this.incompleteReachCount = 0,
    this.notReturnedCount = 0,
    this.thresholdLineY,
    this.thresholdLineX,
  });

  SessionState copyWith({
    int? currentRepetition,
    int? currentSet,
    double? progressPercentage,
    int? elapsedSeconds,
    bool? isCompleted,
    String? feedbackMessage,
    String? secondaryFeedback,
    int? trunkCompensationCount,
    int? incompleteReachCount,
    int? notReturnedCount,
    double? thresholdLineY,
    double? thresholdLineX,
  }) {
    return SessionState(
      currentRepetition: currentRepetition ?? this.currentRepetition,
      currentSet: currentSet ?? this.currentSet,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      secondaryFeedback: secondaryFeedback ?? this.secondaryFeedback,
      trunkCompensationCount: trunkCompensationCount ?? this.trunkCompensationCount,
      incompleteReachCount: incompleteReachCount ?? this.incompleteReachCount,
      notReturnedCount: notReturnedCount ?? this.notReturnedCount,
      thresholdLineY: thresholdLineY ?? this.thresholdLineY,
      thresholdLineX: thresholdLineX ?? this.thresholdLineX,
    );
  }
}

class SessionController extends StateNotifier<SessionState> {
  final String exerciseType;
  final int targetRepetitions;
  final int targetSets;
  final int restSeconds;

  late final ExerciseAnalyzer _analyzer;
  Timer? _timer;
  bool _isCompensationCooldown = false;

  SessionController({
    required this.exerciseType,
    required this.targetRepetitions,
    required this.targetSets,
    required this.restSeconds,
  }) : super(const SessionState()) {
    _analyzer = AnalyzerFactory.createAnalyzer(exerciseType);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isCompleted) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void processPose(Pose pose) {
    if (state.isCompleted) return;

    final result = _analyzer.analyzePose(pose);

    int trunkComp = state.trunkCompensationCount;
    if (result.isCompensating && !_isCompensationCooldown) {
      trunkComp++;
      _isCompensationCooldown = true;
      Future.delayed(const Duration(seconds: 2), () {
        _isCompensationCooldown = false;
      });
    }

    int reps = state.currentRepetition;
    int sets = state.currentSet;
    bool completed = state.isCompleted;

    if (result.repCompleted) {
      reps++;
      if (reps >= targetRepetitions) {
        if (sets >= targetSets) {
          completed = true;
          _timer?.cancel();
        } else {
          sets++;
          reps = 0;
          _analyzer.resetState();
        }
      }
    }

    state = state.copyWith(
      currentRepetition: reps,
      currentSet: sets,
      progressPercentage: result.progressPercentage,
      feedbackMessage: completed ? 'Selesai! Seluruh set berhasil diselesaikan.' : result.feedbackMessage,
      secondaryFeedback: result.secondaryFeedback,
      isCompleted: completed,
      trunkCompensationCount: trunkComp,
      thresholdLineY: result.thresholdLineY,
      thresholdLineX: result.thresholdLineX,
    );
  }
}

typedef SessionParams = ({
  String exerciseId,
  String exerciseType,
  int targetRepetitions,
  int targetSets,
  int restSeconds,
});

final sessionControllerProvider = StateNotifierProvider.family<SessionController, SessionState, SessionParams>((ref, params) {
  return SessionController(
    exerciseType: params.exerciseType,
    targetRepetitions: params.targetRepetitions,
    targetSets: params.targetSets,
    restSeconds: params.restSeconds,
  );
});
