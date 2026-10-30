import 'package:flutter/material.dart';

/// Émotions et humeurs du Journal Intime selon le Cahier des Charges.
enum JournalMoodType {
  happy,
  peaceful,
  inLove,
  grateful,
  motivated,
  tired,
  stressed,
  anxious,
  sad,
  angry;

  String get labelFr {
    switch (this) {
      case JournalMoodType.happy:
        return 'Heureux';
      case JournalMoodType.peaceful:
        return 'Paisible';
      case JournalMoodType.inLove:
        return 'Amoureux';
      case JournalMoodType.grateful:
        return 'Reconnaissant';
      case JournalMoodType.motivated:
        return 'Motivé';
      case JournalMoodType.tired:
        return 'Fatigué';
      case JournalMoodType.stressed:
        return 'Stressé';
      case JournalMoodType.anxious:
        return 'Anxieux';
      case JournalMoodType.sad:
        return 'Triste';
      case JournalMoodType.angry:
        return 'En colère';
    }
  }

  String get labelEn {
    switch (this) {
      case JournalMoodType.happy:
        return 'Happy';
      case JournalMoodType.peaceful:
        return 'Peaceful';
      case JournalMoodType.inLove:
        return 'In Love';
      case JournalMoodType.grateful:
        return 'Grateful';
      case JournalMoodType.motivated:
        return 'Motivated';
      case JournalMoodType.tired:
        return 'Tired';
      case JournalMoodType.stressed:
        return 'Stressed';
      case JournalMoodType.anxious:
        return 'Anxious';
      case JournalMoodType.sad:
        return 'Sad';
      case JournalMoodType.angry:
        return 'Angry';
    }
  }

  String get emoji {
    switch (this) {
      case JournalMoodType.happy:
        return '😊';
      case JournalMoodType.peaceful:
        return '🌿';
      case JournalMoodType.inLove:
        return '🥰';
      case JournalMoodType.grateful:
        return '🙏';
      case JournalMoodType.motivated:
        return '⚡';
      case JournalMoodType.tired:
        return '🥱';
      case JournalMoodType.stressed:
        return '😰';
      case JournalMoodType.anxious:
        return '😟';
      case JournalMoodType.sad:
        return '😢';
      case JournalMoodType.angry:
        return '😡';
    }
  }

  Color get color {
    switch (this) {
      case JournalMoodType.happy:
        return const Color(0xFFE5A93C); // Or chaleureux
      case JournalMoodType.peaceful:
        return const Color(0xFF388E6C); // Vert sauge
      case JournalMoodType.inLove:
        return const Color(0xFFD84A75); // Rose framboise
      case JournalMoodType.grateful:
        return const Color(0xFF7E57C2); // Violet spirituel
      case JournalMoodType.motivated:
        return const Color(0xFFE65100); // Orange énergie
      case JournalMoodType.tired:
        return const Color(0xFF78909C); // Gris bleuté
      case JournalMoodType.stressed:
        return const Color(0xFFF57C00); // Ambre
      case JournalMoodType.anxious:
        return const Color(0xFF8D6E63); // Brun terreux
      case JournalMoodType.sad:
        return const Color(0xFF3F51B5); // Bleu nuit
      case JournalMoodType.angry:
        return const Color(0xFFD32F2F); // Rouge rubis
    }
  }

  static JournalMoodType fromString(String? value) {
    if (value == null) return JournalMoodType.peaceful;
    return JournalMoodType.values.firstWhere(
      (m) => m.name.toLowerCase() == value.toLowerCase(),
      orElse: () => JournalMoodType.peaceful,
    );
  }
}

