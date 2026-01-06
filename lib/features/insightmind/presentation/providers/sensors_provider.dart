// WEEK 6: ACCELEROMETER PROVIDER
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelFeature {
  final double mean;
  final double variance;

  AccelFeature({required this.mean, required this.variance});
}

final accelerometerStreamProvider =
    StreamProvider.autoDispose<AccelerometerEvent>(
      (ref) => accelerometerEvents,
    );

final accelFeatureProvider =
    StateNotifierProvider<AccelFeatureNotifier, AccelFeature>((ref) {
      return AccelFeatureNotifier();
    });

class AccelFeatureNotifier extends StateNotifier<AccelFeature> {
  AccelFeatureNotifier() : super(AccelFeature(mean: 0, variance: 0)) {
    _start();
  }

  final List<double> _buffer = [];

  void _start() {
    accelerometerEvents.listen((event) {
      final mag = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      _buffer.add(mag);
      if (_buffer.length > 50) _buffer.removeAt(0);

      _update();
    });
  }

  void _update() {
    if (_buffer.isEmpty) return;

    final mean = _buffer.reduce((a, b) => a + b) / _buffer.length;

    final variance = _buffer.length > 1
        ? _buffer.fold<double>(0.0, (sum, x) => sum + pow(x - mean, 2)) /
              (_buffer.length - 1)
        : 0.0;

    state = AccelFeature(mean: mean, variance: variance);
  }
}
