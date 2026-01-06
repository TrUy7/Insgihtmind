class HistoryItem {
  final String id;
  final DateTime date;
  final List<int> answers;
  final int score;
  final String riskLevel;
  final String? testType;

  const HistoryItem({
    required this.id,
    required this.date,
    required this.answers,
    required this.score,
    required this.riskLevel,
    this.testType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'answers': answers,
      'score': score,
      'riskLevel': riskLevel,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      date: DateTime.parse(json['date']),
      answers: List<int>.from(json['answers']),
      score: json['score'],
      riskLevel: json['riskLevel'],
    );
  }
}
