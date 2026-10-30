import 'package:intima/core/constants/app_constants.dart';
import 'package:intima/shared/models/menstrual_cycle.dart';

/// Résultat des prédictions pour un cycle menstruel.
class CyclePrediction {
  const CyclePrediction({
    required this.averageCycleDays,
    required this.averagePeriodDays,
    required this.cycleVariabilityDays,
    required this.estimatedNextPeriodStart,
    required this.estimatedFertileWindowStart,
    required this.estimatedFertileWindowEnd,
    required this.estimatedOvulationDate,
    required this.isReliable,
    required this.dataPointsUsed,
    this.insufficientDataReason,
  });

  /// Durée moyenne du cycle en jours.
  final double averageCycleDays;

  /// Durée moyenne des règles en jours.
  final double? averagePeriodDays;

  /// Variabilité (écart-type des durées de cycles).
  final double cycleVariabilityDays;

  /// Date estimée du début des prochaines règles.
  final DateTime? estimatedNextPeriodStart;

  /// Début de la fenêtre de fertilité estimée.
  final DateTime? estimatedFertileWindowStart;

  /// Fin de la fenêtre de fertilité estimée.
  final DateTime? estimatedFertileWindowEnd;

  /// Date d'ovulation estimée.
  final DateTime? estimatedOvulationDate;

  /// Indique si l'estimation est basée sur suffisamment de données.
  final bool isReliable;

  /// Nombre de cycles utilisés pour les calculs.
  final int dataPointsUsed;

  /// Raison de l'insuffisance des données (si non fiable).
  final String? insufficientDataReason;
}

/// Moteur de calcul des cycles menstruels.
///
/// Isolé de toute dépendance d'interface — entièrement testable en isolation.
///
/// AVERTISSEMENT IMPORTANT :
/// Ces estimations sont indicatives. Elles ne constituent pas un outil
/// contraceptif fiable. Les cycles irréguliers, les changements de
/// contraception et d'autres facteurs peuvent rendre les prédictions inexactes.
class CycleCalculationEngine {
  CycleCalculationEngine._();

  /// Calcule toutes les prédictions à partir d'une liste de cycles,
  /// triés du plus ancien au plus récent.
  static CyclePrediction calculate(List<MenstrualCycle> cycles) {
    if (cycles.isEmpty) {
      return _insufficientData('Aucun cycle enregistré.', dataPoints: 0);
    }

    // Trier du plus ancien au plus récent pour les calculs de durée
    final sorted = [...cycles]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    // ─── Durées des cycles ────────────────────────────────────────────────────
    final cycleDurations = _computeCycleDurations(sorted);

    if (cycleDurations.isEmpty) {
      return _insufficientData(
        'Données insuffisantes : au moins 2 cycles sont nécessaires pour calculer une durée.',
        dataPoints: sorted.length,
      );
    }

    final avgCycleDays = _mean(cycleDurations);
    final variability = _standardDeviation(cycleDurations, avgCycleDays);

    // ─── Durées des règles ────────────────────────────────────────────────────
    final periodDurations = sorted
        .where((c) => c.periodDurationDays != null)
        .map((c) => c.periodDurationDays!.toDouble())
        .toList();

    final avgPeriodDays = periodDurations.isNotEmpty
        ? _mean(periodDurations)
        : null;

    // ─── Prédictions ──────────────────────────────────────────────────────────
    final lastCycle = sorted.last;
    final isReliable = cycleDurations.length >= AppConstants.minCyclesForReliableEstimate
        && variability < 7.0; // > 7 jours d'écart-type = très irrégulier

    DateTime? nextPeriodStart;
    DateTime? ovulationDate;
    DateTime? fertileStart;
    DateTime? fertileEnd;

    nextPeriodStart = lastCycle.startDate
        .add(Duration(days: avgCycleDays.round()));

    // Estimation de l'ovulation : cycle moyen - 14 jours (lutéale fixe)
    final ovulationDayFromStart = (avgCycleDays - 14).round().clamp(7, 40);
    ovulationDate = lastCycle.startDate
        .add(Duration(days: ovulationDayFromStart));

    fertileStart = ovulationDate
        .subtract(Duration(days: AppConstants.fertilityDaysBefore));
    fertileEnd = ovulationDate
        .add(Duration(days: AppConstants.fertilityDaysAfter));

    return CyclePrediction(
      averageCycleDays: avgCycleDays,
      averagePeriodDays: avgPeriodDays,
      cycleVariabilityDays: variability,
      estimatedNextPeriodStart: nextPeriodStart,
      estimatedFertileWindowStart: fertileStart,
      estimatedFertileWindowEnd: fertileEnd,
      estimatedOvulationDate: ovulationDate,
      isReliable: isReliable,
      dataPointsUsed: cycleDurations.length,
      insufficientDataReason: isReliable
          ? null
          : cycleDurations.length < AppConstants.minCyclesForReliableEstimate
              ? 'Données insuffisantes (${cycleDurations.length}/${AppConstants.minCyclesForReliableEstimate} cycles requis).'
              : 'Cycles très irréguliers (variabilité : ${variability.toStringAsFixed(1)} jours).',
    );
  }

  /// Calcule les durées de cycles individuels (différence entre débuts consécutifs).
  static List<double> _computeCycleDurations(List<MenstrualCycle> sorted) {
    final durations = <double>[];
    for (var i = 1; i < sorted.length; i++) {
      final diff = sorted[i].startDate
          .difference(sorted[i - 1].startDate)
          .inDays
          .toDouble();
      // Filtrer les valeurs aberrantes (< 15 jours ou > 60 jours)
      if (diff >= 15 && diff <= 60) {
        durations.add(diff);
      }
    }
    return durations;
  }

  /// Retourne les dates sur lesquelles les règles sont prévues dans un mois donné.
  static Set<DateTime> estimatedPeriodDays(
    CyclePrediction prediction,
    int year,
    int month, {
    double periodDays = 5.0,
  }) {
    final result = <DateTime>{};
    final nextStart = prediction.estimatedNextPeriodStart;
    if (nextStart == null) return result;

    final duration = (prediction.averagePeriodDays ?? periodDays).round();

    // Projeter plusieurs cycles futurs et passés dans le mois
    for (var offset = -3; offset <= 3; offset++) {
      final cycleDuration = prediction.averageCycleDays.round();
      final start = nextStart.add(Duration(days: offset * cycleDuration));
      for (var d = 0; d < duration; d++) {
        final day = start.add(Duration(days: d));
        if (day.year == year && day.month == month) {
          result.add(DateTime(day.year, day.month, day.day));
        }
      }
    }
    return result;
  }

  /// Retourne les dates de la fenêtre de fertilité dans un mois donné.
  static Set<DateTime> fertileDaysInMonth(
    CyclePrediction prediction,
    int year,
    int month,
  ) {
    final result = <DateTime>{};
    final fertileStart = prediction.estimatedFertileWindowStart;
    final fertileEnd = prediction.estimatedFertileWindowEnd;
    if (fertileStart == null || fertileEnd == null) return result;

    final cycleDuration = prediction.averageCycleDays.round();
    for (var offset = -2; offset <= 2; offset++) {
      var d = fertileStart.add(Duration(days: offset * cycleDuration));
      final end = fertileEnd.add(Duration(days: offset * cycleDuration));
      while (!d.isAfter(end)) {
        if (d.year == year && d.month == month) {
          result.add(DateTime(d.year, d.month, d.day));
        }
        d = d.add(const Duration(days: 1));
      }
    }
    return result;
  }

  // ─── Statistiques ──────────────────────────────────────────────────────────

  static double _mean(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double _standardDeviation(List<double> values, double mean) {
    if (values.length < 2) return 0;
    final variance = values
        .map((v) => (v - mean) * (v - mean))
        .reduce((a, b) => a + b) / (values.length - 1);
    return variance <= 0 ? 0 : _sqrt(variance);
  }

  /// Racine carrée par méthode de Newton (évite dart:math pour la portabilité).
  static double _sqrt(double value) {
    if (value <= 0) return 0;
    var x = value;
    for (var i = 0; i < 50; i++) {
      x = (x + value / x) / 2;
    }
    return x;
  }

  static CyclePrediction _insufficientData(String reason, {required int dataPoints}) {
    return CyclePrediction(
      averageCycleDays: AppConstants.defaultCycleDays.toDouble(),
      averagePeriodDays: null,
      cycleVariabilityDays: 0,
      estimatedNextPeriodStart: null,
      estimatedFertileWindowStart: null,
      estimatedFertileWindowEnd: null,
      estimatedOvulationDate: null,
      isReliable: false,
      dataPointsUsed: dataPoints,
      insufficientDataReason: reason,
    );
  }
}

