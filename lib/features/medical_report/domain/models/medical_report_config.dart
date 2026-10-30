/// Configuration des options de génération du rapport médical.
class MedicalReportConfig {
  const MedicalReportConfig({
    this.dateRangeMonths = 6,
    this.includeCycles = true,
    this.includeSymptoms = true,
    this.includeSexualHealth = true,
    this.includeContraception = true,
    this.includeCorrelations = true,
    this.includeEncountersCount = false,
    this.anonymizePatientName = false,
    this.consultationReason = '',
  });

  /// Période d'historique en mois (ex: 3, 6, 12)
  final int dateRangeMonths;

  /// Inclure l'historique et les statistiques des cycles menstruels
  final bool includeCycles;

  /// Inclure le récapitulatif des symptômes récurrents
  final bool includeSymptoms;

  /// Inclure les bilans de dépistage IST, vaccins HPV et PrEP
  final bool includeSexualHealth;

  /// Inclure les informations contraceptives
  final bool includeContraception;

  /// Inclure la synthèse des corrélations physiologiques
  final bool includeCorrelations;

  /// Inclure le volume global de rencontres (anonymisé, sans nom)
  final bool includeEncountersCount;

  /// Masquer le prénom sur le document (mentionne "Patient(e)")
  final bool anonymizePatientName;

  /// Motif de la consultation (optionnel)
  final String consultationReason;

  MedicalReportConfig copyWith({
    int? dateRangeMonths,
    bool? includeCycles,
    bool? includeSymptoms,
    bool? includeSexualHealth,
    bool? includeContraception,
    bool? includeCorrelations,
    bool? includeEncountersCount,
    bool? anonymizePatientName,
    String? consultationReason,
  }) {
    return MedicalReportConfig(
      dateRangeMonths: dateRangeMonths ?? this.dateRangeMonths,
      includeCycles: includeCycles ?? this.includeCycles,
      includeSymptoms: includeSymptoms ?? this.includeSymptoms,
      includeSexualHealth: includeSexualHealth ?? this.includeSexualHealth,
      includeContraception: includeContraception ?? this.includeContraception,
      includeCorrelations: includeCorrelations ?? this.includeCorrelations,
      includeEncountersCount: includeEncountersCount ?? this.includeEncountersCount,
      anonymizePatientName: anonymizePatientName ?? this.anonymizePatientName,
      consultationReason: consultationReason ?? this.consultationReason,
    );
  }
}

