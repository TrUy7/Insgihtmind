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

  // --- INI FUNGSI PENTING YANG DIPANGGIL OLEH SENSOR_CAPTURE_PAGE ---
  void updateData(List<double> samples, double mean, double variance) {
    state = state.copyWith(
      samples: samples,
      mean: mean,
      variance: variance,
      capturing: false, // Pastikan status capturing mati
    );
  }

  // Fungsi startCapture/stopCapture bawaan provider ini tidak dipakai lagi
  // karena logika kamera dipindah ke sensor_capture_page.dart
  // Tapi dibiarkan agar tidak error jika ada referensi lain.
  Future<void> startCapture() async { /* ... code lama ... */ }
  Future<void> stopCapture() async { /* ... code lama ... */ }
}