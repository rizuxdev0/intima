import 'package:flutter/material.dart';

import '../../../shared/models/encounter.dart';
import '../../../shared/models/menstrual_cycle.dart';
import '../../journal/domain/models/journal_entry.dart';
import '../../journal/domain/models/journal_mood.dart';

/// Les 4 grandes phases physiologiques d'un cycle menstruel.
enum MenstrualPhase {
  menstrual,
  follicular,
  ovulatory,
  luteal,
  unknown;

  String get labelFr {
    switch (this) {
      case MenstrualPhase.menstrual:
        return 'Phase Menstruelle';
      case MenstrualPhase.follicular:
        return 'Phase Folliculaire';
      case MenstrualPhase.ovulatory:
        return 'Phase Ovulatoire';
      case MenstrualPhase.luteal:
        return 'Phase Lutéale';
      case MenstrualPhase.unknown:
        return 'Phase Indéterminée';
    }
  }

  String get shortName {
    switch (this) {
      case MenstrualPhase.menstrual:
        return 'Règles';
      case MenstrualPhase.follicular:
        return 'Folliculaire';
      case MenstrualPhase.ovulatory:
        return 'Ovulation';
      case MenstrualPhase.luteal:
        return 'Lutéale';
      case MenstrualPhase.unknown:
        return 'Autre';
    }
  }

  String get daysRangeText {
    switch (this) {
      case MenstrualPhase.menstrual:
        return 'Jours 1 à 5';
      case MenstrualPhase.follicular:
        return 'Jours 6 à 13';
      case MenstrualPhase.ovulatory:
        return 'Jours 14 à 16';
      case MenstrualPhase.luteal:
        return 'Jours 17 à 28+';
      case MenstrualPhase.unknown:
        return 'Hors cycle';
    }
  }

  String get emoji {
    switch (this) {
      case MenstrualPhase.menstrual:
        return '🩸';
      case MenstrualPhase.follicular:
        return '🌱';
      case MenstrualPhase.ovulatory:
        return '✨';
      case MenstrualPhase.luteal:
        return '🍂';
      case MenstrualPhase.unknown:
        return '❓';
    }
  }

  Color get color {
    switch (this) {
      case MenstrualPhase.menstrual:
        return const Color(0xFFE57373); // Rouge doux
      case MenstrualPhase.follicular:
        return const Color(0xFF4DB6AC); // Vert turquoise vivifiant
      case MenstrualPhase.ovulatory:
        return const Color(0xFFBA68C8); // Violet lumineux
      case MenstrualPhase.luteal:
        return const Color(0xFFFFB74D); // Ambre chaleureux
      case MenstrualPhase.unknown:
        return Colors.grey;
    }
  }

  String get description {
    switch (this) {
      case MenstrualPhase.menstrual:
        return 'Temps de repos, baisse d\'énergie et renouveau intérieur.';
      case MenstrualPhase.follicular:
        return 'Montée des œstrogènes, regain d\'énergie, curiosité et créativité.';
      case MenstrualPhase.ovulatory:
        return 'Pic hormonal, sociabilité, confiance en soi et libido élevée.';
      case MenstrualPhase.luteal:
        return 'Domination de la progestérone, introspection, sensibilité accrue ou SPM.';
      case MenstrualPhase.unknown:
        return 'Données de cycle insuffisantes pour déterminer la phase exacte.';
    }
  }
}

/// Synthèse émotionnelle et bien-être pour une phase donnée du cycle.
class PhaseMoodSummary {
  const PhaseMoodSummary({
    required this.phase,
    required this.entryCount,
    required this.positiveCount,
    required this.challengingCount,
    required this.averageIntensity,
    required this.encountersCount,
    this.dominantMood,
    this.frequentSymptoms = const [],
  });

  final MenstrualPhase phase;
  final int entryCount;
  final int positiveCount;
  final int challengingCount;
  final double averageIntensity;
  final int encountersCount;
  final JournalMoodType? dominantMood;
  final List<String> frequentSymptoms;

  /// Pourcentage d'écrits à polarité positive (0.0 à 100.0)
  double get positivePercentage {
    if (entryCount == 0) return 0.0;
    return (positiveCount / entryCount) * 100.0;
  }
}

/// Un insight croisé explicatif et bienveillant généré par le moteur.
class CrossInsight {
  const CrossInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.category,
    this.badgeText,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String category;
  final String? badgeText;
}

/// Rapport complet d'analyse des corrélations croisées.
class CorrelationReport {
  const CorrelationReport({
    required this.phaseSummaries,
    required this.insights,
    required this.totalJournalEntries,
    required this.totalEncounters,
    required this.totalCycles,
    required this.hasSufficientData,
    this.peakEnergyPhase,
    this.mostReflectivePhase,
    this.peakIntimacyPhase,
  });

  final List<PhaseMoodSummary> phaseSummaries;
  final List<CrossInsight> insights;
  final int totalJournalEntries;
  final int totalEncounters;
  final int totalCycles;
  final bool hasSufficientData;
  final MenstrualPhase? peakEnergyPhase;
  final MenstrualPhase? mostReflectivePhase;
  final MenstrualPhase? peakIntimacyPhase;

  PhaseMoodSummary summaryFor(MenstrualPhase phase) {
    return phaseSummaries.firstWhere(
      (s) => s.phase == phase,
      orElse: () => PhaseMoodSummary(
        phase: phase,
        entryCount: 0,
        positiveCount: 0,
        challengingCount: 0,
        averageIntensity: 0,
        encountersCount: 0,
      ),
    );
  }
}

/// Moteur algorithmique offline de corrélation Cycle ↔ Humeurs ↔ Intimité.
class CorrelationEngine {
  CorrelationEngine._();

  /// Identifie si une humeur du journal est considérée comme positive / épanouissante.
  static bool isMoodPositive(JournalMoodType mood) {
    switch (mood) {
      case JournalMoodType.happy:
      case JournalMoodType.peaceful:
      case JournalMoodType.inLove:
      case JournalMoodType.grateful:
      case JournalMoodType.motivated:
        return true;
      case JournalMoodType.tired:
      case JournalMoodType.stressed:
      case JournalMoodType.anxious:
      case JournalMoodType.sad:
      case JournalMoodType.angry:
        return false;
    }
  }

  /// Détermine la phase du cycle pour une date donnée à partir de l'historique des cycles.
  static MenstrualPhase determinePhaseForDate(
    DateTime targetDate,
    List<MenstrualCycle> cycles, {
    double averageCycleLength = 28.0,
    double averagePeriodLength = 5.0,
  }) {
    if (cycles.isEmpty) return MenstrualPhase.unknown;

    // Nettoyer l'heure pour comparer des jours
    final targetDay = DateTime(targetDate.year, targetDate.month, targetDate.day);

    // Trouver le cycle le plus proche avant ou à cette date
    final sortedCycles = [...cycles]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    MenstrualCycle? matchingCycle;
    for (int i = sortedCycles.length - 1; i >= 0; i--) {
      final cycleStart = DateTime(
        sortedCycles[i].startDate.year,
        sortedCycles[i].startDate.month,
        sortedCycles[i].startDate.day,
      );
      if (!cycleStart.isAfter(targetDay)) {
        matchingCycle = sortedCycles[i];
        break;
      }
    }

    if (matchingCycle == null) {
      // La date est antérieure au tout premier cycle
      return MenstrualPhase.unknown;
    }

    final cycleStartDay = DateTime(
      matchingCycle.startDate.year,
      matchingCycle.startDate.month,
      matchingCycle.startDate.day,
    );

    final dayInCycle = targetDay.difference(cycleStartDay).inDays + 1;
    if (dayInCycle < 1) return MenstrualPhase.unknown;

    final periodDuration = matchingCycle.periodDurationDays ?? averagePeriodLength.round();
    final totalCycleDays = averageCycleLength.round();

    // Si on dépasse trop la durée moyenne (ex: > 45 jours), phase inconnue ou retard
    if (dayInCycle > 45) {
      return MenstrualPhase.unknown;
    }

    // 1. Phase Menstruelle : Jours 1 à periodDuration
    if (dayInCycle <= periodDuration) {
      return MenstrualPhase.menstrual;
    }

    // Calcul de l'ovulation estimée (typiquement 14 jours avant la fin du cycle)
    final ovulationDay = totalCycleDays - 14 > periodDuration ? totalCycleDays - 14 : 14;

    // 2. Phase Folliculaire : de la fin des règles jusqu'à (ovulation - 2 jours)
    if (dayInCycle < (ovulationDay - 1)) {
      return MenstrualPhase.follicular;
    }

    // 3. Phase Ovulatoire : ovulation +/- 1 jour
    if (dayInCycle >= (ovulationDay - 1) && dayInCycle <= (ovulationDay + 1)) {
      return MenstrualPhase.ovulatory;
    }

    // 4. Phase Lutéale : après l'ovulation jusqu'au prochain cycle
    return MenstrualPhase.luteal;
  }

  /// Analyse les données croisées et produit le rapport complet.
  static CorrelationReport analyze({
    required List<MenstrualCycle> cycles,
    required List<JournalEntry> journalEntries,
    required List<Encounter> encounters,
    double averageCycleDays = 28.0,
    double averagePeriodDays = 5.0,
  }) {
    // Calculer les durées moyennes réelles si disponibles
    if (cycles.length >= 2) {
      final sorted = [...cycles]..sort((a, b) => a.startDate.compareTo(b.startDate));
      final durations = <int>[];
      for (int i = 0; i < sorted.length - 1; i++) {
        final diff = sorted[i + 1].startDate.difference(sorted[i].startDate).inDays;
        if (diff >= 18 && diff <= 45) {
          durations.add(diff);
        }
      }
      if (durations.isNotEmpty) {
        averageCycleDays = durations.reduce((a, b) => a + b) / durations.length;
      }
    }

    final phases = [
      MenstrualPhase.menstrual,
      MenstrualPhase.follicular,
      MenstrualPhase.ovulatory,
      MenstrualPhase.luteal,
    ];

    // Regrouper les écrits de journal par phase
    final entriesByPhase = <MenstrualPhase, List<JournalEntry>>{
      for (final p in phases) p: [],
    };

    for (final entry in journalEntries) {
      final phase = determinePhaseForDate(
        entry.date,
        cycles,
        averageCycleLength: averageCycleDays,
        averagePeriodLength: averagePeriodDays,
      );
      if (entriesByPhase.containsKey(phase)) {
        entriesByPhase[phase]!.add(entry);
      }
    }

    // Regrouper les rencontres par phase
    final encountersByPhase = <MenstrualPhase, int>{
      for (final p in phases) p: 0,
    };

    for (final enc in encounters) {
      final phase = determinePhaseForDate(
        enc.date,
        cycles,
        averageCycleLength: averageCycleDays,
        averagePeriodLength: averagePeriodDays,
      );
      if (encountersByPhase.containsKey(phase)) {
        encountersByPhase[phase] = encountersByPhase[phase]! + 1;
      }
    }

    // Construire les résumés par phase
    final summaries = <PhaseMoodSummary>[];
    for (final phase in phases) {
      final entries = entriesByPhase[phase]!;
      final positiveCount = entries.where((e) => isMoodPositive(e.mood)).length;
      final challengingCount = entries.length - positiveCount;
      final avgIntensity = entries.isEmpty
          ? 0.0
          : entries.map((e) => e.moodIntensity).reduce((a, b) => a + b) / entries.length;

      // Trouver l'humeur dominante
      final moodCounts = <JournalMoodType, int>{};
      for (final e in entries) {
        moodCounts[e.mood] = (moodCounts[e.mood] ?? 0) + 1;
      }
      JournalMoodType? dominant;
      int maxCount = 0;
      moodCounts.forEach((m, c) {
        if (c > maxCount) {
          maxCount = c;
          dominant = m;
        }
      });

      summaries.add(
        PhaseMoodSummary(
          phase: phase,
          entryCount: entries.length,
          positiveCount: positiveCount,
          challengingCount: challengingCount,
          averageIntensity: avgIntensity,
          encountersCount: encountersByPhase[phase] ?? 0,
          dominantMood: dominant,
        ),
      );
    }

    // Déterminer les phases de pic
    MenstrualPhase? peakEnergy;
    double highestPositiveRate = -1;

    MenstrualPhase? mostReflective;
    double highestChallengingRate = -1;

    MenstrualPhase? peakIntimacy;
    int maxEncounters = -1;

    for (final s in summaries) {
      if (s.entryCount >= 2) {
        if (s.positivePercentage > highestPositiveRate) {
          highestPositiveRate = s.positivePercentage;
          peakEnergy = s.phase;
        }
        final challengingRate = 100.0 - s.positivePercentage;
        if (challengingRate > highestChallengingRate) {
          highestChallengingRate = challengingRate;
          mostReflective = s.phase;
        }
      }
      if (s.encountersCount > maxEncounters) {
        maxEncounters = s.encountersCount;
        peakIntimacy = s.phase;
      }
    }

    final hasSufficientData = cycles.isNotEmpty && journalEntries.length >= 3;
    final insights = _generateInsights(
      summaries: summaries,
      peakEnergy: peakEnergy,
      mostReflective: mostReflective,
      peakIntimacy: peakIntimacy,
      hasSufficientData: hasSufficientData,
    );

    return CorrelationReport(
      phaseSummaries: summaries,
      insights: insights,
      totalJournalEntries: journalEntries.length,
      totalEncounters: encounters.length,
      totalCycles: cycles.length,
      hasSufficientData: hasSufficientData,
      peakEnergyPhase: peakEnergy,
      mostReflectivePhase: mostReflective,
      peakIntimacyPhase: peakIntimacy,
    );
  }

  /// Génère une liste d'observations claires, empathiques et scientifiques.
  static List<CrossInsight> _generateInsights({
    required List<PhaseMoodSummary> summaries,
    required MenstrualPhase? peakEnergy,
    required MenstrualPhase? mostReflective,
    required MenstrualPhase? peakIntimacy,
    required bool hasSufficientData,
  }) {
    final list = <CrossInsight>[];

    if (!hasSufficientData) {
      list.add(
        const CrossInsight(
          title: 'Enrichissement des données en cours',
          description:
              'Continuez d\'enregistrer vos humeurs dans le journal et vos cycles. Dès 3 écrits associés à vos cycles, des corrélations personnalisées apparaîtront ici.',
          icon: Icons.lightbulb_outline_rounded,
          accentColor: Color(0xFF7E57C2),
          category: 'Pédagogie',
          badgeText: 'Bientôt disponible',
        ),
      );
      return list;
    }

    // 1. Insight Énergie & Créativité (Phase folliculaire / ovulatoire)
    final folSummary = summaries.firstWhere((s) => s.phase == MenstrualPhase.follicular);
    final ovuSummary = summaries.firstWhere((s) => s.phase == MenstrualPhase.ovulatory);
    final highEnergyEntries = folSummary.entryCount + ovuSummary.entryCount;
    final highEnergyPositives = folSummary.positiveCount + ovuSummary.positiveCount;

    if (highEnergyEntries > 0) {
      final rate = ((highEnergyPositives / highEnergyEntries) * 100).round();
      if (rate >= 60) {
        list.add(
          CrossInsight(
            title: 'Pic de créativité & d\'énergie',
            description:
                '$rate % de vos écrits sous humeur positive coïncident avec vos phases folliculaire et ovulatoire. La montée d\'œstrogènes stimule naturellement votre entrain.',
            icon: Icons.bolt_rounded,
            accentColor: const Color(0xFF4DB6AC),
            category: 'Énergie & Vitalité',
            badgeText: 'Corrélation forte ($rate %)',
          ),
        );
      }
    }

    // 2. Insight Phase Lutéale & Sensibilité (SPM / Écoute de soi)
    final lutealSummary = summaries.firstWhere((s) => s.phase == MenstrualPhase.luteal);
    if (lutealSummary.entryCount > 0) {
      if (lutealSummary.challengingCount >= lutealSummary.positiveCount) {
        list.add(
          CrossInsight(
            title: 'Phase Lutéale : Besoin d\'apaisement',
            description:
                'Vos écrits en phase lutéale révèlent plus de fatigue ou de stress émotionnel. C\'est le moment idéal pour privilégier un rythme calme, un sommeil régulier et la bienveillance envers vous-même.',
            icon: Icons.self_improvement_rounded,
            accentColor: const Color(0xFFFFB74D),
            category: 'Prendre soin de soi',
            badgeText: 'Recommandation',
          ),
        );
      } else {
        list.add(
          CrossInsight(
            title: 'Phase Lutéale sereine et stable',
            description:
                'Vous maintenez une grande stabilité émotionnelle durant votre phase lutéale (${lutealSummary.positivePercentage.round()} % d\'humeurs positives).',
            icon: Icons.spa_rounded,
            accentColor: const Color(0xFF388E6C),
            category: 'Équilibre',
            badgeText: 'Équilibre remarquable',
          ),
        );
      }
    }

    // 3. Insight Intimité & Épanouissement
    if (peakIntimacy != null) {
      final summary = summaries.firstWhere((s) => s.phase == peakIntimacy);
      if (summary.encountersCount > 0) {
        list.add(
          CrossInsight(
            title: 'Rythme intime & Cycle hormonal',
            description:
                'Votre activité intime est particulièrement épanouie en ${summary.phase.labelFr.toLowerCase()} (${summary.encountersCount} rencontre${summary.encountersCount > 1 ? 's' : ''}). L\'harmonie hormonale et le pic de libido s\'alignent naturellement.',
            icon: Icons.favorite_rounded,
            accentColor: const Color(0xFFD84A75),
            category: 'Vie relationnelle',
            badgeText: 'Alignement naturel',
          ),
        );
      }
    }

    // 4. Insight Phase Menstruelle
    final mensSummary = summaries.firstWhere((s) => s.phase == MenstrualPhase.menstrual);
    if (mensSummary.entryCount > 0 && mensSummary.dominantMood != null) {
      list.add(
        CrossInsight(
          title: 'Humeur durant les règles',
          description:
              'Votre émotion la plus fréquente pendant les règles est "${mensSummary.dominantMood!.labelFr}" ${mensSummary.dominantMood!.emoji}. Accorder de l\'attention à vos ressentis physiques et émotionnels facilite chaque cycle.',
          icon: Icons.water_drop_rounded,
          accentColor: const Color(0xFFE57373),
          category: 'Observation corporelle',
          badgeText: mensSummary.dominantMood!.labelFr,
        ),
      );
    }

    return list;
  }
}

