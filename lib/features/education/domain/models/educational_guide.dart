import 'package:flutter/material.dart';

/// Catégories thématiques des fiches et guides bien-être INTIMA.
enum GuideCategory {
  cyclePhysiology,
  stiPrevention,
  consentCommunication,
  wellnessPleasure;

  String get labelFr {
    switch (this) {
      case GuideCategory.cyclePhysiology:
        return 'Cycle & Hormones';
      case GuideCategory.stiPrevention:
        return 'Prévention & IST';
      case GuideCategory.consentCommunication:
        return 'Consentement & Dialogue';
      case GuideCategory.wellnessPleasure:
        return 'Anatomie & Plaisir';
    }
  }

  String get emoji {
    switch (this) {
      case GuideCategory.cyclePhysiology:
        return '🌱';
      case GuideCategory.stiPrevention:
        return '🛡️';
      case GuideCategory.consentCommunication:
        return '💬';
      case GuideCategory.wellnessPleasure:
        return '✨';
    }
  }

  Color get color {
    switch (this) {
      case GuideCategory.cyclePhysiology:
        return const Color(0xFF4DB6AC); // Turquoise
      case GuideCategory.stiPrevention:
        return const Color(0xFF2D5A46); // Vert forêt médical
      case GuideCategory.consentCommunication:
        return const Color(0xFF7E57C2); // Violet profond
      case GuideCategory.wellnessPleasure:
        return const Color(0xFFD84A75); // Rose framboise
    }
  }
}

/// Une section structurée au sein d'une fiche pédagogique.
class GuideSection {
  const GuideSection({
    required this.title,
    required this.paragraphs,
    this.calloutText,
    this.bulletPoints,
  });

  final String title;
  final List<String> paragraphs;
  final String? calloutText;
  final List<String>? bulletPoints;

  Map<String, dynamic> toJson() => {
        'title': title,
        'paragraphs': paragraphs,
        'calloutText': calloutText,
        'bulletPoints': bulletPoints,
      };

  factory GuideSection.fromJson(Map<String, dynamic> json) => GuideSection(
        title: json['title'] as String,
        paragraphs: (json['paragraphs'] as List<dynamic>).cast<String>(),
        calloutText: json['calloutText'] as String?,
        bulletPoints: (json['bulletPoints'] as List<dynamic>?)?.cast<String>(),
      );
}

/// Modèle d'une fiche ou guide pédagogique complet stocké localement.
class EducationalGuide {
  const EducationalGuide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.readingTimeMinutes,
    required this.emoji,
    required this.keyTakeaways,
    required this.sections,
    required this.medicalReviewNote,
    this.tags = const [],
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final GuideCategory category;
  final int readingTimeMinutes;
  final String emoji;
  final List<String> keyTakeaways;
  final List<GuideSection> sections;
  final String medicalReviewNote;
  final List<String> tags;
  final bool isFeatured;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'category': category.index,
        'readingTimeMinutes': readingTimeMinutes,
        'emoji': emoji,
        'keyTakeaways': keyTakeaways,
        'sections': sections.map((s) => s.toJson()).toList(),
        'medicalReviewNote': medicalReviewNote,
        'tags': tags,
        'isFeatured': isFeatured,
      };

  factory EducationalGuide.fromJson(Map<String, dynamic> json) => EducationalGuide(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        category: GuideCategory.values[json['category'] as int],
        readingTimeMinutes: json['readingTimeMinutes'] as int,
        emoji: json['emoji'] as String,
        keyTakeaways: (json['keyTakeaways'] as List<dynamic>).cast<String>(),
        sections: (json['sections'] as List<dynamic>)
            .map((s) => GuideSection.fromJson(s as Map<String, dynamic>))
            .toList(),
        medicalReviewNote: json['medicalReviewNote'] as String,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        isFeatured: json['isFeatured'] as bool? ?? false,
      );
}

