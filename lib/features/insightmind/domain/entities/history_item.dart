import 'package:flutter/foundation.dart';
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
  DateTime parsedDate;
  try {
    if (json['date'] == null) {
      parsedDate = DateTime.now();
    } else if (json['date'] is String) {
      parsedDate = DateTime.parse(json['date']);
    } else if (json['date'] is Map && json['date']['_seconds'] != null) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(json['date']['_seconds'] * 1000);
    } else {
      parsedDate = DateTime.now();
    }
  } catch (e) {
    parsedDate = DateTime.now();
    debugPrint("Gagal parsing tanggal: $e");
  }

  return HistoryItem(
    id: json['id']?.toString() ?? '',
    date: parsedDate,
    // PAKSA elemen list menjadi int murni
    answers: (json['answers'] as List?)
            ?.map((e) => double.parse(e.toString()).toInt())
            .toList() ?? [],
    // PAKSA score menjadi int murni
    score: json['score'] != null 
        ? double.parse(json['score'].toString()).toInt() 
        : 0,
    riskLevel: json['riskLevel']?.toString() ?? 'Tidak Diketahui',
    testType: json['testType']?.toString() ?? 'PHQ-9',
  );
}
}