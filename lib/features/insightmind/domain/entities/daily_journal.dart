class DailyJournal {
  final String id;
  final DateTime date;
  final String content;
  final String mood;

  DailyJournal({
    required this.id,
    required this.date,
    required this.content,
    required this.mood,
  });

  // Pastikan field ini (id, date, content, mood) sama persis dengan req.body di Node.js
  Map<String, dynamic> toJson() => {
    'id': id, 
    'date': date.toIso8601String(),
    'content': content,
    'mood': mood,
  };

  factory DailyJournal.fromJson(Map<String, dynamic> json) => DailyJournal(
    id: json['id'] ?? '',
    date: DateTime.parse(json['date']),
    content: json['content'] ?? '',
    mood: json['mood'] ?? 'Neutral',
  );
}