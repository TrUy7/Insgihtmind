// WEEK 6 UI: BIOMETRIC PAGE
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/sensor_capture_page.dart'; // Pastikan import ini sesuai struktur folder Anda

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

          // ----- PPG CAMERA (Lingkaran Biru pada Request Anda) -----
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
                  // Data ini akan otomatis terupdate setelah scan selesai
                  Text('Mean Y: ${ppg.mean.toStringAsFixed(6)}'),
                  Text('Variance: ${ppg.variance.toStringAsFixed(6)}'),
                  Text('Samples: ${ppg.samples.length}'),

                  const SizedBox(height: 12),

                  FilledButton(
                    onPressed: () {
                      // Navigasi ke halaman Scan Biometrik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SensorCapturePage(),
                        ),
                      );
                    },
                    child: const Text('Buka Scanner'),
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
