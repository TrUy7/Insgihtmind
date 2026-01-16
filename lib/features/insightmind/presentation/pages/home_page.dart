// HOMEPAGE + BIOMETRIC SECTION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sensor_capture_page.dart';

import '../providers/analysis_provider.dart';
import '../providers/score_provider.dart';
import '../providers/history_provider.dart';
import '../providers/sensors_provider.dart';
import '../providers/ppg_provider.dart';

import 'screening_page.dart';
import 'recommendations_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(analysisProvider);
    final answers = ref.watch(answersProvider);

    // BIOMETRIC PROVIDERS
    final accel = ref.watch(accelFeatureProvider);
    final ppg = ref.watch(ppgProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E8), Color(0xFFF3E5F5), Color(0xFFE3F2FD)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 40),

            // ---------------------------------------------------------
            // HERO SECTION (FIXED: Added Expanded & Flex to prevent Overflow)
            // ---------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.psychology_alt_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Selamat Datang di InsightMind',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aplikasi cerdas untuk memantau kesehatan mental Kamu.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Menggunakan Expanded agar tombol menyesuaikan lebar layar
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ScreeningPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.quiz, size: 18),
                          label: const Text("Screening", overflow: TextOverflow.ellipsis),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecommendationsPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lightbulb, size: 18),
                          label: const Text("Rekomendasi", overflow: TextOverflow.ellipsis),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ---------------------------------------------------------
            // QUICK STATS
            // ---------------------------------------------------------
            if (analysis.averageScore > 0 || analysis.journalCount > 0)
              _buildQuickStats(analysis),

            const SizedBox(height: 24),

            // ---------------------------------------------------------
            // RECENT ACTIVITY
            // ---------------------------------------------------------
            if (answers.isNotEmpty) _buildRecentActivity(answers),

            const SizedBox(height: 32),

            // ---------------------------------------------------------
            // FITUR UNGGULAN
            // ---------------------------------------------------------
            _buildFeatureOverview(),

            const SizedBox(height: 32),

            // ---------------------------------------------------------
            // SECTION BARU: SENSOR + BIOMETRIK
            // ---------------------------------------------------------
            const Text(
              "Sensor & Biometrik",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            _buildAccelerometerCard(accel),
            const SizedBox(height: 16),

            _buildPPGCard(ppg, ref, context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// ACCELEROMETER CARD
// ----------------------------------------------------------
Widget _buildAccelerometerCard(accel) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Accelerometer",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Mean: ${accel.mean.toStringAsFixed(4)}"),
          Text("Variance: ${accel.variance.toStringAsFixed(4)}"),
        ],
      ),
    ),
  );
}

// ----------------------------------------------------------
// PPG CAMERA CARD
// ----------------------------------------------------------
Widget _buildPPGCard(ppg, WidgetRef ref, BuildContext context) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PPG via Kamera",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Mean Y: ${ppg.mean.toStringAsFixed(6)}"),
          Text("Variance: ${ppg.variance.toStringAsFixed(6)}"),
          Text("Samples: ${ppg.samples.length}"),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SensorCapturePage(),
                  ),
                );


                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Data biometrik berhasil diperbarui!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("Start Capture"),
            ),
          ),
        ],
      ),
    ),
  );
}

// ----------------------------------------------------------
// QUICK STATS CARD
// ----------------------------------------------------------
Widget _buildQuickStats(analysis) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Row(
          children: const [
            Icon(Icons.insights, color: Color(0xFF6366F1)),
            SizedBox(width: 12),
            Text(
              "Ringkasan Kesehatan Mental",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ModernQuickStatItem(
              label: "Skor Rata-rata",
              value: analysis.averageScore.toString(),
              icon: Icons.score,
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
              ),
            ),
            _ModernQuickStatItem(
              label: "Catatan Harian",
              value: analysis.journalCount.toString(),
              icon: Icons.book,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
              ),
            ),
            _ModernQuickStatItem(
              label: "Risiko",
              value: analysis.overallRisk,
              icon: Icons.warning_amber_rounded,
              gradient: LinearGradient(
                colors: analysis.overallRisk == "Tinggi"
                    ? [const Color(0xFFEF4444), const Color(0xFFF87171)]
                    : analysis.overallRisk == "Sedang"
                    ? [const Color(0xFFF59E0B), const Color(0xFFFBBF24)]
                    : [const Color(0xFF10B981), const Color(0xFF34D399)],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ----------------------------------------------------------
// RECENT ACTIVITY
// ----------------------------------------------------------
Widget _buildRecentActivity(List answers) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.access_time, color: Color(0xFFF59E0B)),
            SizedBox(width: 12),
            Text(
              "Aktivitas Terbaru",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final a in answers)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Jawaban: $a",
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

// ----------------------------------------------------------
// FEATURE OVERVIEW
// ----------------------------------------------------------
Widget _buildFeatureOverview() {
  return Column(
    children: [
      const Text(
        "Fitur Unggulan",
        style: TextStyle(
          fontSize: 24,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        "Temukan semua alat yang Anda butuhkan untuk kesehatan mental yang lebih baik",
        style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      Row(
        children: const [
          Expanded(
            child: _ModernFeatureCard(
              icon: Icons.psychology_alt,
              title: "Tes Psikologis",
              description: "PHQ-9 & DASS-21 screening",
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _ModernFeatureCard(
              icon: Icons.book,
              title: "Catatan Harian",
              description: "Pantau suasana hati dan emosi Anda",
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: const [
          Expanded(
            child: _ModernFeatureCard(
              icon: Icons.bar_chart,
              title: "Laporan & Grafik",
              description: "Visualisasi data kesehatan mental",
              gradient: LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _ModernFeatureCard(
              icon: Icons.lightbulb,
              title: "Rekomendasi AI",
              description: "Saran personal dari Artificial Intelligence",
              gradient: LinearGradient(
                colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

// ----------------------------------------------------------
// REUSABLE UI COMPONENTS
// ----------------------------------------------------------
class _ModernQuickStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _ModernQuickStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;

  const _ModernFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}



