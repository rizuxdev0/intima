import 'package:flutter_test/flutter_test.dart';
import 'package:intima/features/sexual_health/domain/models/prep_record.dart';
import 'package:intima/features/sexual_health/domain/models/sti_screening.dart';
import 'package:intima/features/sexual_health/domain/models/vaccination_record.dart';

void main() {
  group('Sexual Health Models Tests', () {
    test('StiScreening serialization and deserialization', () {
      final now = DateTime(2026, 10, 30);
      final screening = StiScreening(
        id: 'test_scr_01',
        date: now,
        laboratoryOrClinic: 'CeGIDD Central',
        status: ScreeningStatus.negative,
        testedStis: const ['VIH', 'Chlamydia', 'Syphilis'],
        partnerId: 'p1',
        partnerName: 'Lucas',
        nextReminderDate: now.add(const Duration(days: 180)),
        notes: 'Test de routine',
        createdAt: now,
      );

      final json = screening.toJson();
      final restored = StiScreening.fromJson(json);

      expect(restored.id, 'test_scr_01');
      expect(restored.laboratoryOrClinic, 'CeGIDD Central');
      expect(restored.status, ScreeningStatus.negative);
      expect(restored.testedStis.length, 3);
      expect(restored.partnerName, 'Lucas');
      expect(restored.nextReminderDate, isNotNull);
    });

    test('VaccinationRecord progress and completion check', () {
      final now = DateTime(2026, 10, 30);
      final dose1 = VaccinationRecord(
        id: 'vac_01',
        vaccineName: 'HPV (Gardasil 9)',
        doseNumber: 2,
        totalDoses: 3,
        dateAdministered: now,
        createdAt: now,
      );

      expect(dose1.isCompleted, false);

      final doseCompleted = dose1.copyWith(doseNumber: 3);
      expect(doseCompleted.isCompleted, true);
    });

    test('PrepRecord regimen and checkups', () {
      final now = DateTime(2026, 10, 30);
      final prep = PrepRecord(
        regimen: PrepRegimen.daily,
        startDate: now,
        nextKidneyCheckDate: now.add(const Duration(days: 90)),
      );

      final json = prep.toJson();
      final restored = PrepRecord.fromJson(json);

      expect(restored.regimen, PrepRegimen.daily);
      expect(restored.nextKidneyCheckDate, isNotNull);
    });
  });
}

