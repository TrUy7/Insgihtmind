class DailyJournal {
  final String id;
  final DateTime date;
  final String content;
  final String mood; // e.g., 'Happy', 'Sad', 'Neutral', etc.

  const DailyJournal({
    required this.id,
    required this.date,
    required this.content,
    required this.mood,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'mood': mood,
    };
  }

  factory DailyJournal.fromJson(Map<String, dynamic> json) {
    return DailyJournal(
      id: json['id'],
      date: DateTime.parse(json['date']),
      content: json['content'],
      mood: json['mood'],
    );
  }
}
