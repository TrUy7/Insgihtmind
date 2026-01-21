class HistoryItem {
  final String id;
  final DateTime date;
  final List<int> answers;
  final int score;
  final String riskLevel;
  final String testType; // Hilangkan tanda ? agar wajib ada

  const HistoryItem({
    required this.id,
    required this.date,
    required this.answers,
    required this.score,
    required this.riskLevel,
    required this.testType, // Wajib diisi
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'answers': answers,
      'score': score,
      'riskLevel': riskLevel,
      'testType': testType,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id']?.toString() ?? '',
      // Parsing tanggal yang lebih aman
      date: json['date'] != null 
          ? DateTime.parse(json['date'].toString()) 
          : DateTime.now(),
      // Menangani casting List secara eksplisit
      answers: (json['answers'] as List?)?.map((e) => e as int).toList() ?? [],
      // Mencegah error jika score terbaca sebagai double dari JSON
      score: (json['score'] is num) ? (json['score'] as num).toInt() : 0,
      riskLevel: json['riskLevel']?.toString() ?? 'Tidak Diketahui',
      testType: json['testType']?.toString() ?? 'PHQ-9',
    );
  }
}