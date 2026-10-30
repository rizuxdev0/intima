/// Statut global d'un dépistage d'IST.
enum ScreeningStatus {
  negative,
  positive,
  pending;

  String get labelFr {
    switch (this) {
      case ScreeningStatus.negative:
        return 'Négatif (Rassurant)';
      case ScreeningStatus.positive:
        return 'Positif (Traitement requis)';
      case ScreeningStatus.pending:
        return 'En attente des résultats';
    }
  }

  String get labelEn {
    switch (this) {
      case ScreeningStatus.negative:
        return 'Negative (Clear)';
      case ScreeningStatus.positive:
        return 'Positive (Treatment needed)';
      case ScreeningStatus.pending:
        return 'Pending results';
    }
  }
}

/// Enregistrement d'un test de dépistage d'IST/MST.
class StiScreening {
  const StiScreening({
    required this.id,
    required this.date,
    this.laboratoryOrClinic,
    this.status = ScreeningStatus.negative,
    this.testedStis = const [
      'VIH',
      'Chlamydia',
      'Gonorrhée',
      'Syphilis',
      'Hépatite B',
      'Hépatite C',
    ],
    this.partnerId,
    this.partnerName,
    this.nextReminderDate,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final DateTime date;
  final String? laboratoryOrClinic;
  final ScreeningStatus status;
  final List<String> testedStis;
  final String? partnerId;
  final String? partnerName;
  final DateTime? nextReminderDate;
  final String? notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'laboratoryOrClinic': laboratoryOrClinic,
        'status': status.name,
        'testedStis': testedStis,
        'partnerId': partnerId,
        'partnerName': partnerName,
        'nextReminderDate': nextReminderDate?.toIso8601String(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StiScreening.fromJson(Map<String, dynamic> json) => StiScreening(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        laboratoryOrClinic: json['laboratoryOrClinic'] as String?,
        status: ScreeningStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ScreeningStatus.negative,
        ),
        testedStis: (json['testedStis'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        partnerId: json['partnerId'] as String?,
        partnerName: json['partnerName'] as String?,
        nextReminderDate: json['nextReminderDate'] != null
            ? DateTime.parse(json['nextReminderDate'] as String)
            : null,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  StiScreening copyWith({
    String? id,
    DateTime? date,
    String? laboratoryOrClinic,
    ScreeningStatus? status,
    List<String>? testedStis,
    String? partnerId,
    String? partnerName,
    DateTime? nextReminderDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return StiScreening(
      id: id ?? this.id,
      date: date ?? this.date,
      laboratoryOrClinic: laboratoryOrClinic ?? this.laboratoryOrClinic,
      status: status ?? this.status,
      testedStis: testedStis ?? this.testedStis,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      nextReminderDate: nextReminderDate ?? this.nextReminderDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

