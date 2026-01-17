class FeatureVector {
  final double screeningScore;
  final double activityMean;
  final double activityVar;
  final double ppgMean;
  final double ppgVar;

  const FeatureVector({
    required this.screeningScore,
    required this.activityMean,
    required this.activityVar,
    required this.ppgMean,
    required this.ppgVar,
  });

  @override
  String toString() {
    return 'FeatureVector('
        'screeningScore: $screeningScore, '
        'activityMean: $activityMean, '
        'activityVar: $activityVar, '
        'ppgMean: $ppgMean, '
        'ppgVar: $ppgVar'
        ')';
  }
}
