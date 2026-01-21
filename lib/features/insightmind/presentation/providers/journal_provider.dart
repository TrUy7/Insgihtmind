import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/daily_journal.dart';

class JournalNotifier extends StateNotifier<List<DailyJournal>> {
  JournalNotifier() : super([]);

  // --- TAMBAHKAN FUNGSI INI ---
  // Berfungsi untuk mengupdate seluruh daftar jurnal dari backend
  void setJournals(List<DailyJournal> journals) {
    state = journals;
  }

  void addJournal(DailyJournal journal) {
    state = [...state, journal];
  }

  void removeJournal(String id) {
    state = state.where((journal) => journal.id != id).toList();
  }

  void updateJournal(DailyJournal updatedJournal) {
    state = state.map((journal) =>
      journal.id == updatedJournal.id ? updatedJournal : journal
    ).toList();
  }

  // Alias untuk sinkronisasi dengan pemanggilan di UI
  void clearJournal() {
    state = [];
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, List<DailyJournal>>((ref) {
  return JournalNotifier();
});