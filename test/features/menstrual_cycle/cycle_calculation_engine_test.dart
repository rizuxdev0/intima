import 'package:flutter_test/flutter_test.dart';
import 'package:intima/features/menstrual_cycle/domain/cycle_calculation_engine.dart';
import 'package:intima/shared/models/menstrual_cycle.dart';

void main() {
  group('CycleCalculationEngine Tests', () {
    test('Calcul avec une liste vide retourne des données insuffisantes', () {
      final prediction = CycleCalculationEngine.calculate([]);

      expect(prediction.isReliable, isFalse);
      expect(prediction.dataPointsUsed, equals(0));
      expect(prediction.estimatedNextPeriodStart, isNull);
    });

    test('Calcul avec 1 seul cycle ne permet pas de prédire la durée', () {
      final singleCycle = MenstrualCycle(
        id: '1',
        startDate: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
      );

      final prediction = CycleCalculationEngine.calculate([singleCycle]);

      expect(prediction.isReliable, isFalse);
      expect(prediction.dataPointsUsed, equals(1));
      expect(prediction.estimatedNextPeriodStart, isNull);
    });

    test('Calcul avec des cycles réguliers de 28 jours', () {
      final cycles = [
        MenstrualCycle(
          id: '1',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 5),
          createdAt: DateTime(2026, 1, 1),
        ),
        MenstrualCycle(
          id: '2',
          startDate: DateTime(2026, 1, 29), // +28 jours
          endDate: DateTime(2026, 2, 2),
          createdAt: DateTime(2026, 1, 29),
        ),
        MenstrualCycle(
          id: '3',
          startDate: DateTime(2026, 2, 26), // +28 jours
          endDate: DateTime(2026, 3, 2),
          createdAt: DateTime(2026, 2, 26),
        ),
        MenstrualCycle(
          id: '4',
          startDate: DateTime(2026, 3, 26), // +28 jours
          endDate: DateTime(2026, 3, 30),
          createdAt: DateTime(2026, 3, 26),
        ),
      ];

      final prediction = CycleCalculationEngine.calculate(cycles);

      expect(prediction.isReliable, isTrue);
      expect(prediction.averageCycleDays, equals(28.0));
      expect(prediction.averagePeriodDays, equals(5.0));
      expect(prediction.cycleVariabilityDays, lessThan(0.1));
      expect(
        prediction.estimatedNextPeriodStart,
        equals(DateTime(2026, 3, 26).add(const Duration(days: 28))),
      );
    });

    test('Détection des cycles très irréguliers (variabilité > 7 jours)', () {
      final irregularCycles = [
        MenstrualCycle(
          id: '1',
          startDate: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
        MenstrualCycle(
          id: '2',
          startDate: DateTime(2026, 1, 20), // 19 jours
          createdAt: DateTime(2026, 1, 20),
        ),
        MenstrualCycle(
          id: '3',
          startDate: DateTime(2026, 3, 5), // 44 jours
          createdAt: DateTime(2026, 3, 5),
        ),
        MenstrualCycle(
          id: '4',
          startDate: DateTime(2026, 3, 26), // 21 jours
          createdAt: DateTime(2026, 3, 26),
        ),
      ];

      final prediction = CycleCalculationEngine.calculate(irregularCycles);

      expect(prediction.isReliable, isFalse);
      expect(prediction.cycleVariabilityDays, greaterThan(7.0));
      expect(prediction.insufficientDataReason, contains('très irréguliers'));
    });

    test('Fenêtre de fertilité et ovulation estimées correctement', () {
      final cycles = [
        MenstrualCycle(
          id: '1',
          startDate: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
        MenstrualCycle(
          id: '2',
          startDate: DateTime(2026, 1, 29),
          createdAt: DateTime(2026, 1, 29),
        ),
        MenstrualCycle(
          id: '3',
          startDate: DateTime(2026, 2, 26),
          createdAt: DateTime(2026, 2, 26),
        ),
        MenstrualCycle(
          id: '4',
          startDate: DateTime(2026, 3, 26),
          createdAt: DateTime(2026, 3, 26),
        ),
      ];

      final prediction = CycleCalculationEngine.calculate(cycles);

      // Pour un cycle de 28 jours, ovulation = J14 (26 mars + 14 jours = 9 avril)
      expect(prediction.estimatedOvulationDate, equals(DateTime(2026, 4, 9)));

      // Fenêtre fertile = 5 jours avant (4 avril) jusqu'à 1 jour après (10 avril)
      expect(
        prediction.estimatedFertileWindowStart,
        equals(DateTime(2026, 4, 4)),
      );
      expect(
        prediction.estimatedFertileWindowEnd,
        equals(DateTime(2026, 4, 10)),
      );
    });
  });
}

