enum PrepRegimen {
  daily,
  onDemand,
  inactive;

  String get labelFr {
    switch (this) {
      case PrepRegimen.daily:
        return 'PrEP Quotidienne (1 cp / jour)';
      case PrepRegimen.onDemand:
        return 'PrEP À la demande (Schéma 2-1-1)';
      case PrepRegimen.inactive:
        return 'Inactive / Non concerné(e)';
    }
  }

  String get labelEn {
    switch (this) {
      case PrepRegimen.daily:
        return 'Daily PrEP (1 pill / day)';
      case PrepRegimen.onDemand:
        return 'On-demand PrEP (2-1-1 regimen)';
      case PrepRegimen.inactive:
        return 'Inactive / Not applicable';
    }
  }
}

/// Enregistrement du protocole PrEP (prophylaxie pré-exposition VIH).
class PrepRecord {
  const PrepRecord({
    this.regimen = PrepRegimen.inactive,
    this.startDate,
    this.lastKidneyCheckDate,
    this.nextKidneyCheckDate,
    this.nextRefillDate,
    this.notes,
  });

  final PrepRegimen regimen;
  final DateTime? startDate;
  final DateTime? lastKidneyCheckDate;
  final DateTime? nextKidneyCheckDate;
  final DateTime? nextRefillDate;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'regimen': regimen.name,
        'startDate': startDate?.toIso8601String(),
        'lastKidneyCheckDate': lastKidneyCheckDate?.toIso8601String(),
        'nextKidneyCheckDate': nextKidneyCheckDate?.toIso8601String(),
        'nextRefillDate': nextRefillDate?.toIso8601String(),
        'notes': notes,
      };

  factory PrepRecord.fromJson(Map<String, dynamic> json) => PrepRecord(
        regimen: PrepRegimen.values.firstWhere(
          (r) => r.name == json['regimen'],
          orElse: () => PrepRegimen.inactive,
        ),
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'] as String)
            : null,
        lastKidneyCheckDate: json['lastKidneyCheckDate'] != null
            ? DateTime.parse(json['lastKidneyCheckDate'] as String)
            : null,
        nextKidneyCheckDate: json['nextKidneyCheckDate'] != null
            ? DateTime.parse(json['nextKidneyCheckDate'] as String)
            : null,
        nextRefillDate: json['nextRefillDate'] != null
            ? DateTime.parse(json['nextRefillDate'] as String)
            : null,
        notes: json['notes'] as String?,
      );

  PrepRecord copyWith({
    PrepRegimen? regimen,
    DateTime? startDate,
    DateTime? lastKidneyCheckDate,
    DateTime? nextKidneyCheckDate,
    DateTime? nextRefillDate,
    String? notes,
  }) {
    return PrepRecord(
      regimen: regimen ?? this.regimen,
      startDate: startDate ?? this.startDate,
      lastKidneyCheckDate: lastKidneyCheckDate ?? this.lastKidneyCheckDate,
      nextKidneyCheckDate: nextKidneyCheckDate ?? this.nextKidneyCheckDate,
      nextRefillDate: nextRefillDate ?? this.nextRefillDate,
      notes: notes ?? this.notes,
    );
  }
}

