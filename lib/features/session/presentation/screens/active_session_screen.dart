import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';

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
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final poses = await _poseDetector.processImage(inputImage);
    
    // Kirim pose pertama ke controller untuk dianalisa
    if (poses.isNotEmpty) {
      ref.read(sessionControllerProvider(_getParams()).notifier).processPose(poses.first);
    }

    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) setState(() {});
  }

  Map<String, dynamic> _getParams() {
    return {
      'reps': widget.exercise.defaultRepetitions,
      'sets': widget.exercise.defaultSets,
      'romMin': widget.exercise.targetRomMin,
      'romMax': widget.exercise.targetRomMax,
    };
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
          
          // HUD (Heads Up Display)
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
            _buildCompletionOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar(SessionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              const Text('SET', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${state.currentSet} / ${widget.exercise.defaultSets}', 
                   style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            children: [
              const Text('REPETISI', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${state.currentRepetition} / ${widget.exercise.defaultRepetitions}', 
                   style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            children: [
              const Text('SUDUT', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('${state.currentAngle.toInt()}°', 
                   style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBar(SessionState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        state.feedbackMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCompletionOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 24),
            const Text(
              'LATIHAN SELESAI!',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Anda telah menyelesaikan sesi terapi dengan baik.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Kembali ke dashboard
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('KEMBALI KE BERANDA'),
            ),
          ],
        ),
      ),
    );
  }
}
