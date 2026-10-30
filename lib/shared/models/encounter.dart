/// Modèle d'une rencontre / événement intime dans INTIMA.
/// Tous les champs sensibles sont facultatifs.
class Encounter {
  const Encounter({
    required this.id,
    required this.date,
    required this.createdAt,
    this.partnerId,
    this.time,
    this.durationMinutes,
    this.type = EncounterType.intimate,
    this.customTypeName,
    this.notes,
    this.moodBefore,
    this.moodAfter,
    this.protectionUsed,
    this.protectionIssue = false,
    this.contraception,
    this.symptoms = const [],
    this.tags = const [],
    this.followUpReminderId,
  });

  final String id;
  final DateTime date;
  final DateTime createdAt;

  /// Référence optionnelle vers un partenaire
  final String? partnerId;
  final String? time;
  final int? durationMinutes;
  final EncounterType type;

  /// Nom personnalisé si type == custom
  final String? customTypeName;
  final String? notes;

  /// Humeur avant (1-5) — optionnelle
  final int? moodBefore;

  /// Humeur après (1-5) — optionnelle
  final int? moodAfter;
  final ProtectionType? protectionUsed;
  final bool protectionIssue;
  final String? contraception;
  final List<String> symptoms;
  final List<String> tags;
  final String? followUpReminderId;

  /// Label d'affichage neutre pour le mode discret
  String get neutralLabel => 'Événement personnel';

  String get typeLabel {
    switch (type) {
      case EncounterType.intimate:
        return 'Rencontre intime';
      case EncounterType.personal:
        return 'Activité personnelle';
      case EncounterType.custom:
        return customTypeName ?? 'Événement personnalisé';
    }
  }

  Encounter copyWith({
    String? id,
    DateTime? date,
    DateTime? createdAt,
    String? partnerId,
    String? time,
    int? durationMinutes,
    EncounterType? type,
    String? customTypeName,
    String? notes,
    int? moodBefore,
    int? moodAfter,
    ProtectionType? protectionUsed,
    bool? protectionIssue,
    String? contraception,
    List<String>? symptoms,
    List<String>? tags,
    String? followUpReminderId,
  }) {
    return Encounter(
      id: id ?? this.id,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      partnerId: partnerId ?? this.partnerId,
      time: time ?? this.time,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      type: type ?? this.type,
      customTypeName: customTypeName ?? this.customTypeName,
      notes: notes ?? this.notes,
      moodBefore: moodBefore ?? this.moodBefore,
      moodAfter: moodAfter ?? this.moodAfter,
      protectionUsed: protectionUsed ?? this.protectionUsed,
      protectionIssue: protectionIssue ?? this.protectionIssue,
      contraception: contraception ?? this.contraception,
      symptoms: symptoms ?? this.symptoms,
      tags: tags ?? this.tags,
      followUpReminderId: followUpReminderId ?? this.followUpReminderId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'partnerId': partnerId,
        'time': time,
        'durationMinutes': durationMinutes,
        'type': type.index,
        'customTypeName': customTypeName,
        'notes': notes,
        'moodBefore': moodBefore,
        'moodAfter': moodAfter,
        'protectionUsed': protectionUsed?.index,
        'protectionIssue': protectionIssue,
        'contraception': contraception,
        'symptoms': symptoms,
        'tags': tags,
        'followUpReminderId': followUpReminderId,
      };

  factory Encounter.fromJson(Map<String, dynamic> json) => Encounter(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        partnerId: json['partnerId'] as String?,
        time: json['time'] as String?,
        durationMinutes: json['durationMinutes'] as int?,
        type: EncounterType.values[json['type'] as int? ?? 0],
        customTypeName: json['customTypeName'] as String?,
        notes: json['notes'] as String?,
        moodBefore: json['moodBefore'] as int?,
        moodAfter: json['moodAfter'] as int?,
        protectionUsed: json['protectionUsed'] != null
            ? ProtectionType.values[json['protectionUsed'] as int]
            : null,
        protectionIssue: json['protectionIssue'] as bool? ?? false,
        contraception: json['contraception'] as String?,
        symptoms: (json['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        followUpReminderId: json['followUpReminderId'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Encounter && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

enum EncounterType { intimate, personal, custom }

enum ProtectionType { condom, other, none }

