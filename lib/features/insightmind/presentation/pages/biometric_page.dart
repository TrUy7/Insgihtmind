// WEEK 6 UI: BIOMETRIC PAGE
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sensors_provider.dart';
import '../providers/ppg_provider.dart';

class BiometricPage extends ConsumerWidget {
  const BiometricPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accel = ref.watch(accelFeatureProvider);
    final ppg = ref.watch(ppgProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sensor & Biometrik InsightMind')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ----- ACCEL -----
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accelerometer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Mean: ${accel.mean.toStringAsFixed(4)}'),
                  Text('Variance: ${accel.variance.toStringAsFixed(4)}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ----- PPG CAMERA -----
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PPG via Kamera',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Mean Y: ${ppg.mean.toStringAsFixed(6)}'),
                  Text('Variance: ${ppg.variance.toStringAsFixed(6)}'),
                  Text('Samples: ${ppg.samples.length}'),

                  const SizedBox(height: 12),

                  FilledButton(
                    onPressed: () {
                      if (!ppg.capturing) {
                        ref.read(ppgProvider.notifier).startCapture();
                      } else {
                        ref.read(ppgProvider.notifier).stopCapture();
                      }
                    },
                    child: Text(
                      ppg.capturing ? 'Stop Capture' : 'Start Capture',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
