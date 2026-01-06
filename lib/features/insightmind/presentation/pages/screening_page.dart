import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/test_result.dart';
import '../providers/questionnaire_provider.dart';
import '../providers/test_provider.dart';
import '../providers/history_provider.dart';
import '../../domain/entities/history_item.dart';
import 'result_page.dart';

class ScreeningPage extends ConsumerStatefulWidget {
  const ScreeningPage({super.key});

  @override
  ConsumerState<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends ConsumerState<ScreeningPage> {
  String selectedTestType = 'PHQ-9';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih jenis tes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('PHQ-9 (Depresi)'),
                    subtitle: const Text('9 pertanyaan'),
                    value: 'PHQ-9',
                    groupValue: selectedTestType,
                    onChanged: (value) {
                      setState(() => selectedTestType = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('DASS-21'),
                    subtitle: const Text('21 pertanyaan'),
                    value: 'DASS-21',
                    groupValue: selectedTestType,
                    onChanged: (value) {
                      setState(() => selectedTestType = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      selectedTestType == 'PHQ-9'
                          ? 'Patient Health Questionnaire-9'
                          : 'Depression Anxiety Stress Scales-21',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedTestType == 'PHQ-9'
                          ? 'Tes untuk menilai gejala depresi dalam 2 minggu terakhir.'
                          : 'Tes untuk menilai gejala depresi, kecemasan, dan stres.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScreeningQuestionnairePage(testType: selectedTestType),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Mulai Screening'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreeningQuestionnairePage extends ConsumerWidget {
  final String testType;

  const ScreeningQuestionnairePage({super.key, required this.testType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = testType == 'PHQ-9' ? phq9Questions : dass21Questions;
    final qState = ref.watch(questionnaireProvider);

    final progress = questions.isEmpty
        ? 0.0
        : (qState.answers.length / questions.length);

    return Scaffold(
      appBar: AppBar(
        title: Text('$testType Questionnaire'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Progress bar
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Terisi: ${qState.answers.length}/${questions.length} pertanyaan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Questions
          for (int i = 0; i < questions.length; i++) ...[
            _QuestionCard(
              index: i,
              question: questions[i],
              selectedScore: qState.answers[questions[i].id],
              onSelected: (score) {
                ref
                    .read(questionnaireProvider.notifier)
                    .selectAnswer(questionId: questions[i].id, score: score);
              },
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),

          // Submit button
          FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Lihat Hasil'),
            onPressed: () {
              if (!qState.isComplete) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Lengkapi semua pertanyaan sebelum melihat hasil.',
                    ),
                  ),
                );
                return;
              }

              // Convert answers
              final ordered = <int>[];
              for (final q in questions) {
                ordered.add(qState.answers[q.id]!);
              }
              final score = ordered.reduce((a, b) => a + b);

              // Determine risk level based on test type
              String riskLevel;
              if (testType == 'PHQ-9') {
                if (score >= 20) {
                  riskLevel = 'Tinggi';
                } else if (score >= 10) {
                  riskLevel = 'Sedang';
                } else {
                  riskLevel = 'Rendah';
                }
              } else {
                // DASS-21 scoring (simplified)
                if (score >= 42) {
                  riskLevel = 'Tinggi';
                } else if (score >= 21) {
                  riskLevel = 'Sedang';
                } else {
                  riskLevel = 'Rendah';
                }
              }

              // Save to history (legacy format for compatibility)
              ref.read(historyProvider.notifier).addHistoryItem(
                    HistoryItem(
                      id: const Uuid().v4(),
                      date: DateTime.now(),
                      answers: ordered,
                      score: score,
                      riskLevel: riskLevel,
                      testType: testType,
                    ),
                  );

              // Save to test results
              final testResult = TestResult(
                id: const Uuid().v4(),
                date: DateTime.now(),
                testType: testType,
                answers: ordered,
                score: score,
                riskLevel: riskLevel,
              );
              ref.read(testProvider.notifier).addTest(testResult);

              // Reset questionnaire for next use
              ref.read(questionnaireProvider.notifier).reset();

              // Navigate to result
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ScreeningResultPage(testResult: testResult),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ScreeningResultPage extends StatelessWidget {
  final TestResult testResult;

  const ScreeningResultPage({super.key, required this.testResult});

  @override
  Widget build(BuildContext context) {
    String recommendation;
    switch (testResult.riskLevel) {
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
                  Text(
                    testResult.testType,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.psychology_alt,
                    size: 60,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Skor Anda: ${testResult.score}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Tingkat Risiko: ${testResult.riskLevel}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: testResult.riskLevel == 'Tinggi'
                          ? Colors.red
                          : testResult.riskLevel == 'Sedang'
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
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    icon: const Icon(Icons.home),
                    label: const Text('Kembali ke Beranda'),
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

class _TestTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _TestTypeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.indigo : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.quiz,
                size: 32,
                color: isSelected ? Colors.indigo : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.indigo : Colors.black,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.indigo.shade700 : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final Question question;
  final int? selectedScore;
  final ValueChanged<int> onSelected;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedScore,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teks pertanyaan
            Text(
              '${index + 1}. ${question.text}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Opsi jawaban (ChoiceChip)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final opt in question.options)
                  ChoiceChip(
                    label: Text(opt.label),
                    selected: selectedScore == opt.score,
                    onSelected: (_) => onSelected(opt.score),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
