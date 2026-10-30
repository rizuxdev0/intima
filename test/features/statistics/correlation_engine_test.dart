import 'package:flutter_test/flutter_test.dart';
import 'package:intima/features/journal/domain/models/journal_entry.dart';
import 'package:intima/features/journal/domain/models/journal_mood.dart';
import 'package:intima/features/statistics/domain/correlation_engine.dart';
import 'package:intima/shared/models/encounter.dart';
import 'package:intima/shared/models/menstrual_cycle.dart';

void main() {
  group('CorrelationEngine Tests', () {
    final now = DateTime(2026, 10, 30);
    final cycleStart = now.subtract(const Duration(days: 20)); // Cycle démarré le 10/10/2026

    final testCycle = MenstrualCycle(
      id: 'cycle_test',
      startDate: cycleStart,
      endDate: cycleStart.add(const Duration(days: 4)), // J1 à J5 de règles
      createdAt: cycleStart,
    );

    test('Classification exacte des phases du cycle menstruel', () {
      // J1 : Menstruelle
      final phaseJ1 = CorrelationEngine.determinePhaseForDate(
        cycleStart,
        [testCycle],
      );
      expect(phaseJ1, equals(MenstrualPhase.menstrual));

      // J4 : Menstruelle
      final phaseJ4 = CorrelationEngine.determinePhaseForDate(
        cycleStart.add(const Duration(days: 3)),
        [testCycle],
      );
      expect(phaseJ4, equals(MenstrualPhase.menstrual));

      // J8 : Folliculaire (après règles, avant J13)
      final phaseJ8 = CorrelationEngine.determinePhaseForDate(
        cycleStart.add(const Duration(days: 7)),
        [testCycle],
      );
      expect(phaseJ8, equals(MenstrualPhase.follicular));

      // J14 : Ovulatoire (autour de J14)
      final phaseJ14 = CorrelationEngine.determinePhaseForDate(
        cycleStart.add(const Duration(days: 13)),
        [testCycle],
      );
      expect(phaseJ14, equals(MenstrualPhase.ovulatory));

      // J20 : Lutéale (après J15)
      final phaseJ20 = CorrelationEngine.determinePhaseForDate(
        cycleStart.add(const Duration(days: 19)),
        [testCycle],
      );
      expect(phaseJ20, equals(MenstrualPhase.luteal));
    });

    test('Date antérieure au premier cycle retourne MenstrualPhase.unknown', () {
      final ancientDate = cycleStart.subtract(const Duration(days: 10));
      final phase = CorrelationEngine.determinePhaseForDate(
        ancientDate,
        [testCycle],
      );
      expect(phase, equals(MenstrualPhase.unknown));
    });

    test('Polarité des humeurs du journal', () {
      expect(CorrelationEngine.isMoodPositive(JournalMoodType.happy), isTrue);
      expect(CorrelationEngine.isMoodPositive(JournalMoodType.motivated), isTrue);
      expect(CorrelationEngine.isMoodPositive(JournalMoodType.tired), isFalse);
      expect(CorrelationEngine.isMoodPositive(JournalMoodType.stressed), isFalse);
    });

    test('Génération du rapport complet de corrélations avec insights', () {
      final entries = [
        // J2 : Règles -> Paisible
        JournalEntry(
          id: 'e1',
          content: 'Repos',
          date: cycleStart.add(const Duration(days: 1)),
          createdAt: cycleStart.add(const Duration(days: 1)),
          updatedAt: cycleStart.add(const Duration(days: 1)),
          mood: JournalMoodType.peaceful,
          moodIntensity: 3,
          categoryId: 'cat_personal',
        ),
        // J8 : Folliculaire -> Motivé
        JournalEntry(
          id: 'e2',
          content: 'Plein d\'énergie',
          date: cycleStart.add(const Duration(days: 7)),
          createdAt: cycleStart.add(const Duration(days: 7)),
          updatedAt: cycleStart.add(const Duration(days: 7)),
          mood: JournalMoodType.motivated,
          moodIntensity: 5,
          categoryId: 'cat_goals',
        ),
        // J14 : Ovulation -> Heureux
        JournalEntry(
          id: 'e3',
          content: 'Superbe journée',
          date: cycleStart.add(const Duration(days: 13)),
          createdAt: cycleStart.add(const Duration(days: 13)),
          updatedAt: cycleStart.add(const Duration(days: 13)),
          mood: JournalMoodType.happy,
          moodIntensity: 5,
          categoryId: 'cat_love',
        ),
        // J19 : Lutéale -> Fatigué
        JournalEntry(
          id: 'e4',
          content: 'Sensibilité accrue',
          date: cycleStart.add(const Duration(days: 18)),
          createdAt: cycleStart.add(const Duration(days: 18)),
          updatedAt: cycleStart.add(const Duration(days: 18)),
          mood: JournalMoodType.tired,
          moodIntensity: 3,
          categoryId: 'cat_personal',
        ),
      ];

      final encounters = [
        Encounter(
          id: 'enc1',
          date: cycleStart.add(const Duration(days: 13)), // Ovulation
          createdAt: cycleStart.add(const Duration(days: 13)),
          type: EncounterType.intimate,
          protectionUsed: ProtectionType.condom,
        ),
      ];

      final report = CorrelationEngine.analyze(
        cycles: [testCycle],
        journalEntries: entries,
        encounters: encounters,
      );

      expect(report.hasSufficientData, isTrue);
      expect(report.totalJournalEntries, equals(4));
      expect(report.totalEncounters, equals(1));

      // Résumé de la phase menstruelle
      final mensSummary = report.summaryFor(MenstrualPhase.menstrual);
      expect(mensSummary.entryCount, equals(1));
      expect(mensSummary.dominantMood, equals(JournalMoodType.peaceful));

      // Résumé de l'ovulation
      final ovuSummary = report.summaryFor(MenstrualPhase.ovulatory);
      expect(ovuSummary.entryCount, equals(1));
      expect(ovuSummary.encountersCount, equals(1));

      // Au moins 2 insights générés
      expect(report.insights.length, greaterThanOrEqualTo(2));
    });
  });
}
