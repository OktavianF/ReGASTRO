import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../exercise/domain/entities/exercise_entity.dart';
import '../controllers/session_controller.dart';
import '../painters/pose_painter.dart';
import '../widgets/camera_view.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  final ExerciseEntity exercise;

  const ActiveSessionScreen({super.key, required this.exercise});

  @override
  ConsumerState<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;

    final poses = await _poseDetector.processImage(inputImage);
    final sessionState = ref.read(sessionControllerProvider(_getParams()));
    
    if (poses.isNotEmpty) {
      ref.read(sessionControllerProvider(_getParams()).notifier).processPose(poses.first);
    }

    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        thresholdLineY: sessionState.thresholdLineY,
        thresholdLineX: sessionState.thresholdLineX,
        targetReached: sessionState.progressPercentage >= 95.0,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) setState(() {});
  }

  SessionParams _getParams() {
    return (
      exerciseId: widget.exercise.id,
      exerciseType: widget.exercise.exerciseType,
      targetRepetitions: widget.exercise.defaultRepetitions,
      targetSets: widget.exercise.defaultSets,
      restSeconds: widget.exercise.restSeconds,
    );
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionControllerProvider(_getParams()));

    return Scaffold(
      body: Stack(
        children: [
          CameraView(
            customPaint: _customPaint,
            onImage: _processImage,
            initialDirection: CameraLensDirection.front,
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTopBar(sessionState),
                _buildFeedbackBar(sessionState),
              ],
            ),
          ),

          if (sessionState.isCompleted)
            _buildCompletionOverlay(sessionState),
        ],
      ),
    );
  }

  Widget _buildTopBar(SessionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.black87,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Column(
                children: [
                  const Text('SET', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text('${state.currentSet} / ${widget.exercise.defaultSets}', 
                       style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: [
                  const Text('REPETISI', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text('${state.currentRepetition} / ${widget.exercise.defaultRepetitions}', 
                       style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: [
                  const Text('DURASI', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(_formatDuration(state.elapsedSeconds), 
                       style: const TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: state.progressPercentage / 100.0,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              state.progressPercentage >= 95.0 ? Colors.greenAccent : Colors.cyanAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBar(SessionState state) {
    final isWarning = state.secondaryFeedback != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? Colors.orange.shade900.withOpacity(0.9) : Colors.blue.shade900.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning ? Colors.amber : Colors.cyanAccent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            state.feedbackMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (state.secondaryFeedback != null) ...[
            const SizedBox(height: 6),
            Text(
              '⚠️ ${state.secondaryFeedback!}',
              style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildCompletionOverlay(SessionState state) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'LATIHAN SELESAI!',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Durasi: ${_formatDuration(state.elapsedSeconds)} | Total Repetisi: ${widget.exercise.defaultRepetitions * widget.exercise.defaultSets}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Kompensasi Trunk: ${state.trunkCompensationCount} kali',
                    style: TextStyle(
                      color: state.trunkCompensationCount > 0 ? Colors.orangeAccent : Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('KEMBALI KE BERANDA', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
