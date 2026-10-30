/// Modèle d'un cycle menstruel dans INTIMA.
/// Chaque cycle est lié à un profil utilisateur ou un partenaire (avec consentement).
class MenstrualCycle {
  const MenstrualCycle({
    required this.id,
    required this.startDate,
    required this.createdAt,
    this.profileId = 'self',
    this.endDate,
    this.predictedStartDate,
    this.flowIntensity,
    this.symptoms = const [],
    this.observations,
    this.treatment,
    this.isPregnancy = false,
    this.isPostPartum = false,
    this.isIrregular = false,
    this.schemaVersion = 1,
  });

  final String id;
  final DateTime startDate;
  final DateTime createdAt;

  /// Identifie à qui appartient ce cycle ('self' ou un partnerId avec consentement)
  final String profileId;

  final DateTime? endDate;
  final DateTime? predictedStartDate;

  /// Intensité des saignements : 0=légère, 1=moyenne, 2=abondante
  final int? flowIntensity;

  final List<CycleSymptom> symptoms;
  final String? observations;
  final String? treatment;
  final bool isPregnancy;
  final bool isPostPartum;
  final bool isIrregular;
  final int schemaVersion;

  /// Durée des règles en jours (si la date de fin est connue)
  int? get periodDurationDays {
    if (endDate == null) return null;
    return endDate!.difference(startDate).inDays + 1;
  }

  MenstrualCycle copyWith({
    String? id,
    DateTime? startDate,
    DateTime? createdAt,
    String? profileId,
    DateTime? endDate,
    DateTime? predictedStartDate,
    int? flowIntensity,
    List<CycleSymptom>? symptoms,
    String? observations,
    String? treatment,
    bool? isPregnancy,
    bool? isPostPartum,
    bool? isIrregular,
  }) {
    return MenstrualCycle(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      profileId: profileId ?? this.profileId,
      endDate: endDate ?? this.endDate,
      predictedStartDate: predictedStartDate ?? this.predictedStartDate,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      symptoms: symptoms ?? this.symptoms,
      observations: observations ?? this.observations,
      treatment: treatment ?? this.treatment,
      isPregnancy: isPregnancy ?? this.isPregnancy,
      isPostPartum: isPostPartum ?? this.isPostPartum,
      isIrregular: isIrregular ?? this.isIrregular,
      schemaVersion: schemaVersion,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'profileId': profileId,
        'endDate': endDate?.toIso8601String(),
        'predictedStartDate': predictedStartDate?.toIso8601String(),
        'flowIntensity': flowIntensity,
        'symptoms': symptoms.map((s) => s.toJson()).toList(),
        'observations': observations,
        'treatment': treatment,
        'isPregnancy': isPregnancy,
        'isPostPartum': isPostPartum,
        'isIrregular': isIrregular,
        'schemaVersion': schemaVersion,
      };

  factory MenstrualCycle.fromJson(Map<String, dynamic> json) => MenstrualCycle(
        id: json['id'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        profileId: json['profileId'] as String? ?? 'self',
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        predictedStartDate: json['predictedStartDate'] != null
            ? DateTime.parse(json['predictedStartDate'] as String)
            : null,
        flowIntensity: json['flowIntensity'] as int?,
        symptoms: (json['symptoms'] as List<dynamic>?)
                ?.map((e) => CycleSymptom.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        observations: json['observations'] as String?,
        treatment: json['treatment'] as String?,
        isPregnancy: json['isPregnancy'] as bool? ?? false,
        isPostPartum: json['isPostPartum'] as bool? ?? false,
        isIrregular: json['isIrregular'] as bool? ?? false,
        schemaVersion: json['schemaVersion'] as int? ?? 1,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MenstrualCycle && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Symptôme enregistré lors d'un cycle.
class CycleSymptom {
  const CycleSymptom({
    required this.date,
    required this.type,
    this.intensity,
    this.note,
  });

  final DateTime date;
  final SymptomType type;

  /// Intensité 1-5 (optionnelle)
  final int? intensity;
  final String? note;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'type': type.index,
        'intensity': intensity,
        'note': note,
      };

  factory CycleSymptom.fromJson(Map<String, dynamic> json) => CycleSymptom(
        date: DateTime.parse(json['date'] as String),
        type: SymptomType.values[json['type'] as int],
        intensity: json['intensity'] as int?,
        note: json['note'] as String?,
      );
}

enum SymptomType {
  cramps,
  fatigue,
  headache,
  moodSwings,
  bloating,
  breastTenderness,
  acne,
  backPain,
  nausea,
  insomnia,
  spotting,
  other,
}

