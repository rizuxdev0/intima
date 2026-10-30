/// Enregistrement de vaccination préventive liée à la santé sexuelle.
class VaccinationRecord {
  const VaccinationRecord({
    required this.id,
    required this.vaccineName, // ex: HPV (Gardasil 9), Hépatite B, etc.
    required this.doseNumber,
    required this.totalDoses,
    required this.dateAdministered,
    this.nextDoseDate,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String vaccineName;
  final int doseNumber;
  final int totalDoses;
  final DateTime dateAdministered;
  final DateTime? nextDoseDate;
  final String? notes;
  final DateTime createdAt;

  bool get isCompleted => doseNumber >= totalDoses;

  Map<String, dynamic> toJson() => {
        'id': id,
        'vaccineName': vaccineName,
        'doseNumber': doseNumber,
        'totalDoses': totalDoses,
        'dateAdministered': dateAdministered.toIso8601String(),
        'nextDoseDate': nextDoseDate?.toIso8601String(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) =>
      VaccinationRecord(
        id: json['id'] as String,
        vaccineName: json['vaccineName'] as String,
        doseNumber: json['doseNumber'] as int? ?? 1,
        totalDoses: json['totalDoses'] as int? ?? 3,
        dateAdministered: DateTime.parse(json['dateAdministered'] as String),
        nextDoseDate: json['nextDoseDate'] != null
            ? DateTime.parse(json['nextDoseDate'] as String)
            : null,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  VaccinationRecord copyWith({
    String? id,
    String? vaccineName,
    int? doseNumber,
    int? totalDoses,
    DateTime? dateAdministered,
    DateTime? nextDoseDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return VaccinationRecord(
      id: id ?? this.id,
      vaccineName: vaccineName ?? this.vaccineName,
      doseNumber: doseNumber ?? this.doseNumber,
      totalDoses: totalDoses ?? this.totalDoses,
      dateAdministered: dateAdministered ?? this.dateAdministered,
      nextDoseDate: nextDoseDate ?? this.nextDoseDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

