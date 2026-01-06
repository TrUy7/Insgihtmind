import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/daily_journal.dart';
import 'package:uuid/uuid.dart';

class JournalNotifier extends StateNotifier<List<DailyJournal>> {
  JournalNotifier() : super([]);

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

  void clearJournals() {
    state = [];
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, List<DailyJournal>>((ref) {
  return JournalNotifier();
});
