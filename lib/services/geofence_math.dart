/// Calculs purs du geofencing — extraits de GeofencingService pour être
/// testables unitairement (voir test/geofence_math_test.dart).
class GeofenceMath {
  GeofenceMath._();

  /// Confiance dans la position GPS selon la précision rapportée (mètres).
  /// 1.0 = excellent signal, 0.3 = signal douteux.
  static double confidenceForAccuracy(double accuracyMeters) {
    if (accuracyMeters < 10) {
      return 1.0;
    }
    if (accuracyMeters < 20) {
      return 0.7;
    }
    if (accuracyMeters <= 30) {
      return 0.5;
    }
    return 0.3;
  }

  /// Rayon de déclenchement effectif: élargi quand la confiance GPS est
  /// faible (jusqu'à +50 %), borné par [maxMultiplier].
  static double effectiveRadius({
    required int triggerRadiusM,
    required double confidence,
    required double maxMultiplier,
  }) {
    final multiplier = 1 + (1 - confidence) * 0.5;
    final cappedMultiplier = multiplier.clamp(1.0, maxMultiplier);
    return triggerRadiusM * cappedMultiplier;
  }

  /// L'utilisateur s'approche-t-il du POI?
  ///
  /// [distances] = distances au POI en ordre chronologique (plus ancien →
  /// plus récent). Retourne true si la tendance moyenne est décroissante,
  /// ou si l'utilisateur est quasi stationnaire (variation totale < 5 m),
  /// ou s'il n'y a pas assez d'échantillons pour trancher.
  static bool isApproaching(List<double> distances) {
    if (distances.length < 2) {
      return true;
    }

    final deltas = <double>[];
    for (var index = 1; index < distances.length; index++) {
      deltas.add(distances[index] - distances[index - 1]);
    }

    final averageDelta =
        deltas.reduce((sum, value) => sum + value) / deltas.length;
    final totalVariation = distances.last - distances.first;

    if (totalVariation.abs() < 5.0) {
      return true;
    }

    return averageDelta <= 0;
  }
}
