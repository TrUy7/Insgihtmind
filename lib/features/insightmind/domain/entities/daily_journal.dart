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

factory DailyJournal.fromJson(Map<String, dynamic> json) {
  return DailyJournal(
    id: json['id']?.toString() ?? '',
    // Gunakan tryParse agar lebih aman
    date: json['date'] != null 
        ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now()) 
        : DateTime.now(),
    content: json['content']?.toString() ?? '',
    mood: json['mood']?.toString() ?? 'Neutral',
  );
}
}