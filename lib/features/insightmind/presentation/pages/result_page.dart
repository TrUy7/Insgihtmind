import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/score_provider.dart';
import '../../domain/entities/test_result.dart';

class ResultPage extends ConsumerWidget {
  final TestResult? result;

  const ResultPage({super.key, this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayResult = result;
    if (displayResult == null) {
      return const Scaffold(
        body: Center(child: Text('No result available')),
      );
    }

    String recommendation;
    switch (displayResult.riskLevel) {
      case 'Tinggi':
        recommendation =
            'Pertimbangkan untuk berbicara dengan konselor atau psikolog. '
            'Kurangi beban, istirahat cukup, dan hubungi layanan kampus.';
        break;
      case 'Sedang':
        recommendation =
            'Lakukan aktivitas relaksasi (napas dalam, olahraga ringan), '
            'atur waktu, dan evaluasi beban kuliah atau kerja.';
        break;
      default:
        recommendation =
            'Pertahankan kebiasaan baik. '
            'Jaga tidur, pola makan, dan olahraga secara teratur.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Screening')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_objects,
                    size: 60,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Skor Anda: ${displayResult.score}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Tingkat Risiko: ${displayResult.riskLevel}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: displayResult.riskLevel == 'Tinggi'
                          ? Colors.red
                          : displayResult.riskLevel == 'Sedang'
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    recommendation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
