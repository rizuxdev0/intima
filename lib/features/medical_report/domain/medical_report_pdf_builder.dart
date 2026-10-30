import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../shared/models/app_preferences.dart';
import '../../../shared/models/encounter.dart';
import '../../../shared/models/menstrual_cycle.dart';
import '../../menstrual_cycle/domain/cycle_calculation_engine.dart';
import '../../sexual_health/data/sexual_health_repository.dart';
import '../../sexual_health/domain/models/prep_record.dart';
import '../../sexual_health/domain/models/sti_screening.dart';
import '../../statistics/domain/correlation_engine.dart';
import 'models/medical_report_config.dart';

/// Générateur de rapport médical PDF confidentiel pour consultation.
class MedicalReportPdfBuilder {
  MedicalReportPdfBuilder._();

  static Future<Uint8List> build({
    required MedicalReportConfig config,
    required AppPreferences prefs,
    required List<MenstrualCycle> cycles,
    required SexualHealthData sexualHealth,
    required List<Encounter> encounters,
    CyclePrediction? prediction,
    CorrelationReport? correlationReport,
  }) async {
    final pdf = pw.Document(
      title: 'Dossier Médical INTIMA',
      author: 'INTIMA Private Health',
    );

    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final cutoffDate = now.subtract(Duration(days: config.dateRangeMonths * 30));

    // Filtrer les cycles selon la période choisie
    final relevantCycles = cycles
        .where((c) => !c.startDate.isBefore(cutoffDate))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate)); // Plus récent en premier

    // Filtrer les dépistages IST selon la période
    final relevantScreenings = sexualHealth.screenings
        .where((s) => !s.date.isBefore(cutoffDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Couleurs de thème PDF
    const primaryColor = PdfColor.fromInt(0xFF88293E); // Grenat Intima
    const secondaryColor = PdfColor.fromInt(0xFF2D5A46); // Vert médical
    const greyColor = PdfColor.fromInt(0xFF666666);
    const lightGreyColor = PdfColor.fromInt(0xFFF3F3F3);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(
          context,
          config,
          prefs,
          now,
          cutoffDate,
          dateFormat,
          primaryColor,
          greyColor,
        ),
        footer: (context) => _buildFooter(context, greyColor),
        build: (context) => [
          // Motif de consultation (si renseigné)
          if (config.consultationReason.trim().isNotEmpty) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              margin: const pw.EdgeInsets.only(bottom: 16),
              decoration: pw.BoxDecoration(
                color: lightGreyColor,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: primaryColor, width: 0.5),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Motif de consultation : ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      config.consultationReason.trim(),
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ─── Section 1 : Cycles Menstruels ──────────────────────────────────────────
          if (config.includeCycles) ...[
            _buildSectionTitle('1. SYNTHÈSE DES CYCLES MENSTRUELS', primaryColor),
            pw.SizedBox(height: 6),
            if (prediction != null && relevantCycles.isNotEmpty) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricBox(
                    'Durée moyenne cycle',
                    '${prediction.averageCycleDays.round()} jours',
                    secondaryColor,
                  ),
                  _buildMetricBox(
                    'Durée moyenne règles',
                    prediction.averagePeriodDays != null
                        ? '${prediction.averagePeriodDays!.round()} jours'
                        : 'N/A',
                    primaryColor,
                  ),
                  _buildMetricBox(
                    'Régularité (écart-type)',
                    '± ${prediction.cycleVariabilityDays.toStringAsFixed(1)} j (${prediction.cycleVariabilityDays <= 3.0 ? 'Régulier' : 'Variable'})',
                    prediction.cycleVariabilityDays <= 3.0 ? secondaryColor : PdfColors.orange800,
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
            ],

            // Tableau des cycles
            if (relevantCycles.isNotEmpty) ...[
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: lightGreyColor),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellAlignment: pw.Alignment.centerLeft,
                headers: ['Date début', 'Date fin', 'Durée règles', 'Flux déclaré', 'Observation'],
                data: relevantCycles.map((c) {
                  final flowText = c.flowIntensity == 0
                      ? 'Léger'
                      : (c.flowIntensity == 1
                          ? 'Moyen'
                          : (c.flowIntensity == 2 ? 'Abondant' : 'Non précisé'));
                  final duration = c.periodDurationDays != null
                      ? '${c.periodDurationDays} jours'
                      : 'En cours';
                  return [
                    dateFormat.format(c.startDate),
                    c.endDate != null ? dateFormat.format(c.endDate!) : '-',
                    duration,
                    flowText,
                    c.observations ?? (c.isIrregular ? 'Cycle irrégulier' : 'Normal'),
                  ];
                }).toList(),
              ),
            ] else ...[
              pw.Text('Aucun cycle enregistré sur la période sélectionnée.',
                  style: const pw.TextStyle(fontSize: 10, color: greyColor)),
            ],
            pw.SizedBox(height: 18),
          ],

          // ─── Section 2 : Symptômes & Dysménorrhées ──────────────────────────────────
          if (config.includeSymptoms) ...[
            _buildSectionTitle('2. SYMPTÔMES & MANIFESTATIONS PHYSIQUES', primaryColor),
            pw.SizedBox(height: 6),
            _buildSymptomsTable(relevantCycles, dateFormat),
            pw.SizedBox(height: 18),
          ],

          // ─── Section 3 : Santé Sexuelle, Dépistages & Vaccins ───────────────────────
          if (config.includeSexualHealth) ...[
            _buildSectionTitle('3. SANTÉ SEXUELLE, DÉPISTAGES & PRÉVENTION', primaryColor),
            pw.SizedBox(height: 6),
            pw.Text(
              'Historique des bilans de dépistage IST :',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5),
            ),
            pw.SizedBox(height: 4),
            if (relevantScreenings.isNotEmpty) ...[
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5),
                headerDecoration: const pw.BoxDecoration(color: lightGreyColor),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: ['Date', 'Centre / Laboratoire', 'Pathogènes recherchés', 'Résultat'],
                data: relevantScreenings.map((s) {
                  final statusText = s.status == ScreeningStatus.negative
                      ? 'NÉGATIF (Sérologie rassurante)'
                      : (s.status == ScreeningStatus.pending ? 'En attente' : 'Positif');
                  return [
                    dateFormat.format(s.date),
                    (s.laboratoryOrClinic != null && s.laboratoryOrClinic!.isNotEmpty)
                        ? s.laboratoryOrClinic!
                        : 'Laboratoire de ville',
                    s.testedStis.join(', '),
                    statusText,
                  ];
                }).toList(),
              ),
            ] else ...[
              pw.Text('Aucun dépistage enregistré sur la période.',
                  style: const pw.TextStyle(fontSize: 9, color: greyColor)),
            ],

            pw.SizedBox(height: 10),
            pw.Text(
              'Couverture vaccinale & Prophylaxie :',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5),
            ),
            pw.SizedBox(height: 4),
            if (sexualHealth.vaccinations.isNotEmpty) ...[
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5),
                headerDecoration: const pw.BoxDecoration(color: lightGreyColor),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: ['Vaccin', 'Dose administrée', 'Dernière injection', 'Statut du schéma'],
                data: sexualHealth.vaccinations.map((v) {
                  final isComplete = v.doseNumber >= v.totalDoses;
                  return [
                    v.vaccineName,
                    'Dose ${v.doseNumber} sur ${v.totalDoses}',
                    dateFormat.format(v.dateAdministered),
                    isComplete ? 'Schéma complet' : 'Dose de rappel à planifier',
                  ];
                }).toList(),
              ),
            ],
            if (sexualHealth.prep.regimen != PrepRegimen.inactive) ...[
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: lightGreyColor,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  children: [
                    pw.Text('Traitement préventif PrEP : ',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                    pw.Text(
                      sexualHealth.prep.regimen == PrepRegimen.daily
                          ? 'Prise quotidienne en continu'
                          : 'Schéma à la demande (2-1-1)',
                      style: const pw.TextStyle(fontSize: 8.5),
                    ),
                  ],
                ),
              ),
            ],
            pw.SizedBox(height: 18),
          ],

          // ─── Section 4 : Espace d'Annotation Médicale ───────────────────────────────
          _buildSectionTitle('4. REMARQUES & PRESCRIPTIONS DU PRATICIEN', primaryColor),
          pw.SizedBox(height: 6),
          pw.Container(
            height: 90,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Espace réservé au professionnel de santé (observations, examens prescrits, conseils) :',
                    style: const pw.TextStyle(fontSize: 8, color: greyColor),
                  ),
                  pw.Spacer(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Date : ___ / ___ / ______',
                          style: const pw.TextStyle(fontSize: 8, color: greyColor)),
                      pw.Text('Signature & Cachet du médecin :',
                          style: const pw.TextStyle(fontSize: 8, color: greyColor)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(
    pw.Context context,
    MedicalReportConfig config,
    AppPreferences prefs,
    DateTime now,
    DateTime cutoffDate,
    DateFormat dateFormat,
    PdfColor primaryColor,
    PdfColor greyColor,
  ) {
    final patientName = config.anonymizePatientName
        ? 'Confidentiel (Patient/e)'
        : (prefs.userName.isNotEmpty ? prefs.userName : 'Patient/e');
    final currentYear = now.year;
    final ageText = prefs.birthYear != null
        ? '${currentYear - prefs.birthYear!} ans (${prefs.birthYear})'
        : 'Non renseigné';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INTIMA',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.Text(
                  'DOSSIER MÉDICAL & AUTO-SUIVI GYNÉCOLOGIQUE',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Édité le : ${dateFormat.format(now)}',
                    style: const pw.TextStyle(fontSize: 8.5)),
                pw.Text(
                  'Période : ${dateFormat.format(cutoffDate)} au ${dateFormat.format(now)} (${config.dateRangeMonths} mois)',
                  style: pw.TextStyle(fontSize: 8.5, color: greyColor),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF7F7F7),
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Patient(e) : $patientName',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
              pw.Text('Âge : $ageText', style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Génération locale : 100% Hors-Ligne',
                  style: pw.TextStyle(fontSize: 8.5, color: greyColor)),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Divider(thickness: 1, color: primaryColor),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context, PdfColor greyColor) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5, color: PdfColors.grey300),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'INTIMA Private Tracker - Document confidentiel soumis au secret médical.',
              style: pw.TextStyle(fontSize: 7.5, color: greyColor),
            ),
            pw.Text(
              'Page ${context.pageNumber} sur ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 7.5, color: greyColor),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static pw.Widget _buildMetricBox(String label, String value, PdfColor color) {
    return pw.Container(
      width: 160,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSymptomsTable(List<MenstrualCycle> cycles, DateFormat dateFormat) {
    final allSymptoms = <String, List<int>>{}; // Type -> liste des intensités

    for (final c in cycles) {
      for (final s in c.symptoms) {
        final name = _symptomNameFr(s.type);
        allSymptoms.putIfAbsent(name, () => []).add(s.intensity ?? 3);
      }
    }

    if (allSymptoms.isEmpty) {
      return pw.Text('Aucun symptôme particulier enregistré lors des cycles récents.',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700));
    }

    final tableData = allSymptoms.entries.map((entry) {
      final occurrences = entry.value.length;
      final avgIntensity = entry.value.reduce((a, b) => a + b) / occurrences;
      return [
        entry.key,
        '$occurrences fois',
        '${avgIntensity.toStringAsFixed(1)} / 5',
        avgIntensity >= 3.5 ? 'Intensité marquée' : 'Intensité modérée',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5),
      headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF3F3F3)),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headers: ['Symptôme récurrent', 'Fréquence', 'Intensité moyenne', 'Observation clinique'],
      data: tableData,
    );
  }

  static String _symptomNameFr(SymptomType type) {
    switch (type) {
      case SymptomType.cramps:
        return 'Dysménorrhées (Crampes pelviennes)';
      case SymptomType.fatigue:
        return 'Fatigue / Asthénie';
      case SymptomType.headache:
        return 'Céphalées / Migraines';
      case SymptomType.moodSwings:
        return 'Variations d\'humeur (SPM)';
      case SymptomType.bloating:
        return 'Ballonnements / Rétention';
      case SymptomType.breastTenderness:
        return 'Tension mammaire (Mastodynie)';
      case SymptomType.acne:
        return 'Acné hormonale';
      case SymptomType.backPain:
        return 'Douleurs lombaires';
      case SymptomType.nausea:
        return 'Nausées';
      case SymptomType.insomnia:
        return 'Troubles du sommeil';
      case SymptomType.spotting:
        return 'Spotting (Saignements intermenstruels)';
      case SymptomType.other:
        return 'Autre manifestation';
    }
  }
}
