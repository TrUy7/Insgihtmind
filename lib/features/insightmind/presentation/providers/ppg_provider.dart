// WEEK 6: CAMERA BASED PPG-LIKE PROVIDER
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PpgState {
  final bool capturing;
  final List<double> samples;
  final double mean;
  final double variance;

  PpgState({
    required this.capturing,
    required this.samples,
    required this.mean,
    required this.variance,
  });

  PpgState copyWith({
    bool? capturing,
    List<double>? samples,
    double? mean,
    double? variance,
  }) {
    return PpgState(
      capturing: capturing ?? this.capturing,
      samples: samples ?? this.samples,
      mean: mean ?? this.mean,
      variance: variance ?? this.variance,
    );
  }
}

final ppgProvider = StateNotifierProvider<PpgNotifier, PpgState>((ref) {
  return PpgNotifier();
});

class PpgNotifier extends StateNotifier<PpgState> {
  PpgNotifier()
      : super(PpgState(capturing: false, samples: [], mean: 0, variance: 0));

  CameraController? _controller;

  // Fungsi untuk update manual dari file lain
  void updateData(List<double> samples, double mean, double variance) {
    state = state.copyWith(
      samples: samples,
      mean: mean,
      variance: variance,
    );
  }

  Future<void> startCapture() async {
    if (state.capturing) return;

    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception("No camera found");

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
    );

    await _controller!.initialize();
    state = state.copyWith(capturing: true);

    _controller!.startImageStream((image) {
      if (!state.capturing) return;

      final plane = image.planes[0];
      final buffer = plane.bytes;

      double sum = 0;
      int count = 0;

      for (int i = 0; i < buffer.length; i += 50) {
        sum += buffer[i];
        count++;
      }

      final meanY = sum / max(1, count);
      final newSamples = [...state.samples, meanY];
      if (newSamples.length > 300) newSamples.removeAt(0);

      final mean = newSamples.reduce((a, b) => a + b) / newSamples.length.toDouble();

      final variance = newSamples.length > 1
          ? newSamples.fold<double>(0.0, (s, x) => s + pow(x - mean, 2)) /
          (newSamples.length - 1)
          : 0.0;

      state = state.copyWith(
        samples: newSamples,
        mean: mean,
        variance: variance,
      );
    });
  }

  Future<void> stopCapture() async {
    if (_controller != null) {
      try {
        await _controller!.stopImageStream();
      } catch (_) {}
      await _controller!.dispose();
    }
    _controller = null;
    state = state.copyWith(capturing: false);
  }
}