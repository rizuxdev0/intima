import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/features/medical_report/domain/medical_report_pdf_builder.dart';
import 'package:intima/features/medical_report/domain/models/medical_report_config.dart';
import 'package:intima/features/menstrual_cycle/domain/cycle_calculation_engine.dart';
import 'package:intima/features/sexual_health/data/sexual_health_repository.dart';
import 'package:intima/features/sexual_health/domain/models/prep_record.dart';
import 'package:intima/features/sexual_health/domain/models/sti_screening.dart';
import 'package:intima/features/sexual_health/domain/models/vaccination_record.dart';
import 'package:intima/shared/models/app_preferences.dart';
import 'package:intima/shared/models/encounter.dart';
import 'package:intima/shared/models/menstrual_cycle.dart';

void main() {
  group('MedicalReportPdfBuilder Tests', () {
    final now = DateTime.now();

    final testCycles = [
      MenstrualCycle(
        id: 'cycle_1',
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.subtract(const Duration(days: 26)),
        flowIntensity: 1,
        symptoms: [
          CycleSymptom(
            date: now.subtract(const Duration(days: 30)),
            type: SymptomType.cramps,
            intensity: 4,
          ),
          CycleSymptom(
            date: now.subtract(const Duration(days: 29)),
            type: SymptomType.fatigue,
            intensity: 3,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];

    final testScreening = StiScreening(
      id: 'screen_1',
      date: now.subtract(const Duration(days: 45)),
      laboratoryOrClinic: 'CeGIDD Test Clinic',
      status: ScreeningStatus.negative,
      testedStis: const ['VIH', 'Chlamydia', 'Gonorrhée'],
      createdAt: now.subtract(const Duration(days: 45)),
    );

    final testVaccine = VaccinationRecord(
      id: 'vac_1',
      vaccineName: 'HPV (Gardasil 9)',
      doseNumber: 2,
      totalDoses: 3,
      dateAdministered: now.subtract(const Duration(days: 60)),
      createdAt: now.subtract(const Duration(days: 60)),
    );

    const testPrefs = AppPreferences(
      userName: 'Alexandre',
      birthYear: 1998,
    );

    test('Génération d\'un document PDF binaire valide (%PDF)', () async {
      final config = const MedicalReportConfig(
        dateRangeMonths: 6,
        consultationReason: 'Contrôle gynécologique de routine',
        includeCycles: true,
        includeSymptoms: true,
        includeSexualHealth: true,
        anonymizePatientName: false,
      );

      final pdfBytes = await MedicalReportPdfBuilder.build(
        config: config,
        prefs: testPrefs,
        cycles: testCycles,
        sexualHealth: SexualHealthData(
          screenings: [testScreening],
          vaccinations: [testVaccine],
          prep: const PrepRecord(regimen: PrepRegimen.inactive),
        ),
        encounters: const <Encounter>[],
        prediction: CycleCalculationEngine.calculate(testCycles),
      );

      expect(pdfBytes, isNotEmpty);
      // Les fichiers PDF commencent obligatoirement par les octets magiques "%PDF"
      final magicHeader = utf8.decode(pdfBytes.sublist(0, 4));
      expect(magicHeader, equals('%PDF'));
    });

    test('Option d\'anonymisation respectée dans la génération', () async {
      final anonConfig = const MedicalReportConfig(
        anonymizePatientName: true,
      );

      final pdfBytes = await MedicalReportPdfBuilder.build(
        config: anonConfig,
        prefs: testPrefs,
        cycles: testCycles,
        sexualHealth: const SexualHealthData(),
        encounters: const <Encounter>[],
      );

      expect(pdfBytes, isNotEmpty);
      final magicHeader = utf8.decode(pdfBytes.sublist(0, 4));
      expect(magicHeader, equals('%PDF'));
    });
  });
}
