import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'history_provider.dart';
import 'journal_provider.dart';
import 'test_provider.dart';

class AnalysisData {
  final int averageScore;
  final String overallRisk;
  final int journalCount;
  final Map<String, int> moodCounts;
  final List<Map<String, dynamic>> recentTrends;

  const AnalysisData({
    required this.averageScore,
    required this.overallRisk,
    required this.journalCount,
    required this.moodCounts,
    required this.recentTrends,
  });
}

final analysisProvider = Provider<AnalysisData>((ref) {
  final history = ref.watch(historyProvider);
  final journals = ref.watch(journalProvider);
  final tests = ref.watch(testProvider);

  // Combine all scores
  final allScores = <int>[];
  allScores.addAll(history.map((h) => h.score));
  allScores.addAll(tests.map((t) => t.score));

  final averageScore = allScores.isEmpty ? 0 : (allScores.reduce((a, b) => a + b) / allScores.length).round();

  // Determine overall risk based on average
  String overallRisk;
  if (averageScore >= 20) {
    overallRisk = 'Tinggi';
  } else if (averageScore >= 10) {
    overallRisk = 'Sedang';
  } else {
    overallRisk = 'Rendah';
  }

  // Mood analysis from journals
  final moodCounts = <String, int>{};
  for (final journal in journals) {
    moodCounts[journal.mood] = (moodCounts[journal.mood] ?? 0) + 1;
  }

  // Recent trends (last 7 days)
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  final recentHistory = history.where((h) => h.date.isAfter(weekAgo)).toList();
  final recentTests = tests.where((t) => t.date.isAfter(weekAgo)).toList();
  final recentTrends = <Map<String, dynamic>>[];

  for (final h in recentHistory) {
    recentTrends.add({
      'date': h.date,
      'score': h.score,
      'type': 'Screening',
    });
  }
  for (final t in recentTests) {
    recentTrends.add({
      'date': t.date,
      'score': t.score,
      'type': t.testType,
    });
  }

  recentTrends.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

  return AnalysisData(
    averageScore: averageScore,
    overallRisk: overallRisk,
    journalCount: journals.length,
    moodCounts: moodCounts,
    recentTrends: recentTrends,
  );
});
