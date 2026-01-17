import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/history_item.dart';
import 'package:uuid/uuid.dart';

class HistoryNotifier extends StateNotifier<List<HistoryItem>> {
  HistoryNotifier() : super([]);

  void addHistory(HistoryItem item) {
    state = [...state, item];
  }

  void addHistoryItem(HistoryItem item) {
    state = [...state, item];
  }

  void removeHistory(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clearHistory() {
    state = [];
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryItem>>((ref) {
  return HistoryNotifier();
});
