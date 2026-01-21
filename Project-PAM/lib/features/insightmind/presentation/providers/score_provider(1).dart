import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/calculate_risk_level.dart';
import '../../../insightmind/data/repositories/score_repository.dart';

final answersProvider = StateProvider<List<int>>((ref) => []);

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepository();
});

final calculateRiskProvider = Provider<CalculateRiskLevel>((ref) {
  return CalculateRiskLevel();
});

final scoreProvider = Provider<int>((ref) {
  final repo = ref.watch(scoreRepositoryProvider);
  final answers = ref.watch(answersProvider);
  return repo.calculateScore(answers);
});

final resultProvider = Provider((ref) {
  final score = ref.watch(scoreProvider);
  final usecase = ref.watch(calculateRiskProvider);
  return usecase.execute(score);
});