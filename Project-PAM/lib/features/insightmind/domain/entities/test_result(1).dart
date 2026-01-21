class TestResult {
  final String id;
  final DateTime date;
  final String testType; // 'PHQ-9' or 'DASS-21'
  final List<int> answers;
  final int score;
  final String riskLevel;

  const TestResult({
    required this.id,
    required this.date,
    required this.testType,
    required this.answers,
    required this.score,
    required this.riskLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'testType': testType,
      'answers': answers,
      'score': score,
      'riskLevel': riskLevel,
    };
  }

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'],
      date: DateTime.parse(json['date']),
      testType: json['testType'],
      answers: List<int>.from(json['answers']),
      score: json['score'],
      riskLevel: json['riskLevel'],
    );
  }
}
