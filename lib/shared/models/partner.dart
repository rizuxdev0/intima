import 'package:flutter/material.dart';

/// Modèle d'un partenaire dans INTIMA.
/// Toutes les informations identifiantes sont facultatives.
class Partner {
  const Partner({
    required this.id,
    required this.createdAt,
    this.name,
    this.color = 0xFF6D426D,
    this.emoji,
    this.firstMetDate,
    this.notes,
    this.tags = const [],
    this.isArchived = false,
    this.privacyLevel = 0,
    this.photoPath,
    this.cycleProfileId,
  });

  final String id;
  final DateTime createdAt;

  /// Nom, pseudonyme ou surnom (facultatif pour préserver la vie privée)
  final String? name;

  /// Couleur ARGB personnalisée pour l'avatar
  final int color;

  /// Emoji optionnel comme avatar alternatif
  final String? emoji;

  final DateTime? firstMetDate;
  final String? notes;
  final List<String> tags;
  final bool isArchived;

  /// 0 = standard, 1 = protégé (demande PIN pour consulter)
  final int privacyLevel;
  final String? photoPath;

  /// Identifiant du profil de cycle menstruel associé (si pertinent)
  final String? cycleProfileId;

  String get displayName => name?.isNotEmpty == true ? name! : 'Partenaire';

  Color get colorValue => Color(color);

  Partner copyWith({
    String? id,
    DateTime? createdAt,
    String? name,
    int? color,
    String? emoji,
    DateTime? firstMetDate,
    String? notes,
    List<String>? tags,
    bool? isArchived,
    int? privacyLevel,
    String? photoPath,
    String? cycleProfileId,
  }) {
    return Partner(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      color: color ?? this.color,
      emoji: emoji ?? this.emoji,
      firstMetDate: firstMetDate ?? this.firstMetDate,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      isArchived: isArchived ?? this.isArchived,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      photoPath: photoPath ?? this.photoPath,
      cycleProfileId: cycleProfileId ?? this.cycleProfileId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'name': name,
        'color': color,
        'emoji': emoji,
        'firstMetDate': firstMetDate?.toIso8601String(),
        'notes': notes,
        'tags': tags,
        'isArchived': isArchived,
        'privacyLevel': privacyLevel,
        'photoPath': photoPath,
        'cycleProfileId': cycleProfileId,
      };

  factory Partner.fromJson(Map<String, dynamic> json) => Partner(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        name: json['name'] as String?,
        color: json['color'] as int? ?? 0xFF6D426D,
        emoji: json['emoji'] as String?,
        firstMetDate: json['firstMetDate'] != null
            ? DateTime.parse(json['firstMetDate'] as String)
            : null,
        notes: json['notes'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        isArchived: json['isArchived'] as bool? ?? false,
        privacyLevel: json['privacyLevel'] as int? ?? 0,
        photoPath: json['photoPath'] as String?,
        cycleProfileId: json['cycleProfileId'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Partner && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

