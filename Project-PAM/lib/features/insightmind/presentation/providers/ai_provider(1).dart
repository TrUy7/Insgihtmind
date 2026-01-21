// WEEK7: Provider inferensi AI
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind_app/features/insightmind/domain/predict_risk_ai.dart';
import 'package:insightmind_app/features/models/feature_vector.dart';

final aiPredictorProvider = Provider<PredictRiskAI>((ref) {
  return PredictRiskAI();
});

final aiResultProvider = Provider.family<Map<String, dynamic>, FeatureVector>((
  ref,
  fv,
) {
  final model = ref.watch(aiPredictorProvider);
  return model.predict(fv);
});
