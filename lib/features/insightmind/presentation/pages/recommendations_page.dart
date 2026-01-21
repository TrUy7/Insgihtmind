import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analysis_provider.dart';

class RecommendationsPage extends ConsumerWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(analysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saran & Rekomendasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Status
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Status Saat Ini',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        analysis.overallRisk == 'Tinggi'
                            ? Icons.warning
                            : analysis.overallRisk == 'Sedang'
                                ? Icons.info
                                : Icons.check_circle,
                        size: 48,
                        color: analysis.overallRisk == 'Tinggi'
                            ? Colors.red
                            : analysis.overallRisk == 'Sedang'
                                ? Colors.orange
                                : Colors.green,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Risiko: ${analysis.overallRisk}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: analysis.overallRisk == 'Tinggi'
                                  ? Colors.red
                                  : analysis.overallRisk == 'Sedang'
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                          Text('Skor Rata-rata: ${analysis.averageScore}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Personalized Recommendations
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rekomendasi Personal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._getPersonalizedRecommendations(analysis),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // General Tips
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tips Umum untuk Kesehatan Mental',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTipItem(
                    icon: Icons.bed,
                    title: 'Tidur yang Cukup',
                    description: 'Usahakan tidur 7-9 jam per malam. Jaga jadwal tidur yang teratur.',
                  ),
                  _buildTipItem(
                    icon: Icons.restaurant,
                    title: 'Pola Makan Sehat',
                    description: 'Konsumsi makanan bergizi, hindari junk food, dan jaga hidrasi.',
                  ),
                  _buildTipItem(
                    icon: Icons.directions_run,
                    title: 'Olahraga Teratur',
                    description: 'Lakukan aktivitas fisik minimal 40 menit per hari seperti jalan kaki.',
                  ),
                  _buildTipItem(
                    icon: Icons.people,
                    title: 'Sosialisasi',
                    description: 'Jaga hubungan dengan keluarga dan teman.',
                  ),
                  _buildTipItem(
                    icon: Icons.self_improvement,
                    title: 'Teknik Relaksasi',
                    description: 'Praktikkan meditasi, deep breathing, atau hobi yang menenangkan.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // When to Seek Help
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kapan Harus Mencari Bantuan Profesional',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Segera hubungi profesional kesehatan mental jika Anda mengalami:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildWarningItem('Pikiran untuk menyakiti diri sendiri atau orang lain'),
                  _buildWarningItem('Kesulitan berfungsi dalam kehidupan sehari-hari'),
                  _buildWarningItem('Gejala yang semakin parah dan tidak membaik'),
                  _buildWarningItem('Perubahan drastis dalam perilaku atau suasana hati'),
                  const SizedBox(height: 16),
                  const Text(
                    'Di Indonesia, Anda dapat menghubungi:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildContactItem('Hotline Kesehatan Jiwa', '119 (ext. 8)'),
                  _buildContactItem('Sahabat Jiwa', '021-500-454'),
                  _buildContactItem('Layanan Kampus', 'Konsultasikan dengan counselor kampus'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getPersonalizedRecommendations(AnalysisData analysis) {
    final recommendations = <Widget>[];

    if (analysis.overallRisk == 'Tinggi') {
      recommendations.addAll([
        _buildRecommendationItem(
          icon: Icons.warning,
          title: 'Konsultasi Profesional',
          description: 'Segera hubungi psikolog atau psikiater untuk evaluasi mendalam.',
          color: Colors.red,
        ),
        _buildRecommendationItem(
          icon: Icons.home,
          title: 'Istirahat yang Cukup',
          description: 'Kurangi beban kerja/studi, prioritaskan istirahat dan recovery.',
          color: Colors.orange,
        ),
        _buildRecommendationItem(
          icon: Icons.support,
          title: 'Dukungan Sosial',
          description: 'Bicarakan dengan orang terdekat atau keluarga tentang perasaan Anda.',
          color: Colors.blue,
        ),
      ]);
    } else if (analysis.overallRisk == 'Sedang') {
      recommendations.addAll([
        _buildRecommendationItem(
          icon: Icons.schedule,
          title: 'Kelola Waktu',
          description: 'Buat jadwal yang realistis, sisihkan waktu untuk istirahat dan hobi.',
          color: Colors.orange,
        ),
        _buildRecommendationItem(
          icon: Icons.spa,
          title: 'Teknik Relaksasi',
          description: 'Coba meditasi, yoga, atau aktivitas yang membantu mengurangi stres.',
          color: Colors.green,
        ),
        _buildRecommendationItem(
          icon: Icons.track_changes,
          title: 'Pantau Perkembangan',
          description: 'Lanjutkan menggunakan aplikasi ini untuk memantau kondisi Anda.',
          color: Colors.blue,
        ),
      ]);
    } else {
      recommendations.addAll([
        _buildRecommendationItem(
          icon: Icons.check_circle,
          title: 'Pertahankan Pola Baik',
          description: 'Lanjutkan kebiasaan sehat yang sudah Anda lakukan.',
          color: Colors.green,
        ),
        _buildRecommendationItem(
          icon: Icons.book,
          title: 'Jurnal Harian',
          description: 'Catat pengalaman positif dan hal-hal yang Anda syukuri.',
          color: Colors.blue,
        ),
        _buildRecommendationItem(
          icon: Icons.group,
          title: 'Berbagi dengan Orang Lain',
          description: 'Bagikan pengalaman positif Anda untuk menginspirasi orang lain.',
          color: Colors.purple,
        ),
      ]);
    }

    // Mood-based recommendations
    if (analysis.moodCounts.isNotEmpty) {
      final mostCommonMood = analysis.moodCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      if (mostCommonMood.toLowerCase() == 'sad') {
        recommendations.add(_buildRecommendationItem(
          icon: Icons.wb_sunny,
          title: 'Tingkatkan Aktivitas Positif',
          description: 'Coba lakukan aktivitas yang biasanya membuat Anda bahagia.',
          color: Colors.yellow,
        ));
      } else if (mostCommonMood.toLowerCase() == 'angry') {
        recommendations.add(_buildRecommendationItem(
          icon: Icons.self_improvement,
          title: 'Teknik Manajemen Emosi',
          description: 'Pelajari teknik seperti deep breathing untuk mengelola emosi.',
          color: Colors.red,
        ));
      }
    }

    return recommendations;
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String name, String contact) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.phone, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$name: $contact',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
