import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/test_result.dart';
import 'package:uuid/uuid.dart';

class TestNotifier extends StateNotifier<List<TestResult>> {
  TestNotifier() : super([]);

  void addTest(TestResult test) {
    state = [...state, test];
  }

  void removeTest(String id) {
    state = state.where((test) => test.id != id).toList();
  }

  void clearTests() {
    state = [];
  }
}

final testProvider =
    StateNotifierProvider<TestNotifier, List<TestResult>>((ref) {
  return TestNotifier();
});
