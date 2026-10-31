import 'package:flutter/material.dart';

/// Catégorie pour organiser les entrées du Journal Intime.
class JournalCategory {
  const JournalCategory({
    required this.id,
    required this.name,
    this.nameEn,
    required this.iconCode,
    required this.colorValue,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final String? nameEn;
  final int iconCode;
  final int colorValue;
  final bool isDefault;

  /// Renvoie l'icône Material correspondante sous forme de constante
  /// pour garantir la compatibilité avec le tree-shaking Flutter en mode release.
  IconData get icon {
    switch (id) {
      case 'cat_personal':
        return Icons.person_rounded;
      case 'cat_love':
        return Icons.favorite_rounded;
      case 'cat_family':
        return Icons.diversity_1_rounded;
      case 'cat_reflections':
        return Icons.psychology_rounded;
      case 'cat_goals':
        return Icons.flag_rounded;
      case 'cat_memories':
        return Icons.auto_awesome_rounded;
      case 'cat_work':
        return Icons.work_rounded;
      case 'cat_studies':
        return Icons.school_rounded;
      case 'cat_other':
        return Icons.category_rounded;
      default:
        return _iconFromCode(iconCode);
    }
  }

  static IconData _iconFromCode(int code) {
    if (code == Icons.person_rounded.codePoint) return Icons.person_rounded;
    if (code == Icons.favorite_rounded.codePoint) return Icons.favorite_rounded;
    if (code == Icons.diversity_1_rounded.codePoint) return Icons.diversity_1_rounded;
    if (code == Icons.psychology_rounded.codePoint) return Icons.psychology_rounded;
    if (code == Icons.flag_rounded.codePoint) return Icons.flag_rounded;
    if (code == Icons.auto_awesome_rounded.codePoint) return Icons.auto_awesome_rounded;
    if (code == Icons.work_rounded.codePoint) return Icons.work_rounded;
    if (code == Icons.school_rounded.codePoint) return Icons.school_rounded;
    if (code == Icons.category_rounded.codePoint) return Icons.category_rounded;
    return Icons.folder_rounded;
  }
  Color get color => Color(colorValue);

  String localizedName(String locale) {
    if (locale.startsWith('en') && nameEn != null && nameEn!.isNotEmpty) {
      return nameEn!;
    }
    return name;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameEn': nameEn,
        'iconCode': iconCode,
        'colorValue': colorValue,
        'isDefault': isDefault,
      };

  factory JournalCategory.fromJson(Map<String, dynamic> json) => JournalCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        nameEn: json['nameEn'] as String?,
        iconCode: json['iconCode'] as int? ?? Icons.folder_rounded.codePoint,
        colorValue: json['colorValue'] as int? ?? 0xFF88293E,
        isDefault: json['isDefault'] as bool? ?? false,
      );

  static List<JournalCategory> get defaultCategories => [
        const JournalCategory(
          id: 'cat_personal',
          name: 'Vie personnelle',
          nameEn: 'Personal Life',
          iconCode: 0xe491, // Icons.person_rounded
          colorValue: 0xFF88293E,
          isDefault: true,
        ),
        const JournalCategory(
          id: 'cat_love',
          name: 'Amour et relations',
          nameEn: 'Love & Relationships',
          iconCode: 0xe25b, // Icons.favorite_rounded
          colorValue: 0xFFC97A63,
          isDefault: true,
        ),
        const JournalCategory(
          id: 'cat_family',
          name: 'Famille',
          nameEn: 'Family',
          iconCode: 0xe28e, // Icons.diversity_1_rounded
          colorValue: 0xFF388E6C,
          isDefault: true,
        ),
        const JournalCategory(
          id: 'cat_reflections',
          name: 'Réflexions',
          nameEn: 'Reflections',
          iconCode: 0xe597, // Icons.psychology_rounded
          colorValue: 0xFF7E57C2,
          isDefault: true,
        ),
        const JournalCategory(
          id: 'cat_goals',
          name: 'Objectifs personnels',
          nameEn: 'Personal Goals',
          iconCode: 0xf028c, // Icons.flag_rounded
          colorValue: 0xFFE65100,
          isDefault: true,
        ),
        const JournalCategory(
          id: 'cat_memories',
          name: 'Souvenirs',
          nameEn: 'Memories',
          iconCode: 0xe0b2, // Icons.auto_awesome_rounded
          colorValue: 0xFFE5A93C,
          isDefault: true,
        ),
        const JournalCategory(
          id: 'cat_work',
          name: 'Travail',
          nameEn: 'Work',
          iconCode: 0xe6f2, // Icons.work_rounded
          colorValue: 0xFF455A64,
          isDefault: true,
        ),
        const JournalCategory(
          id: 'cat_studies',
          name: 'Études',
          nameEn: 'Studies',
          iconCode: 0xe559, // Icons.school_rounded
          colorValue: 0xFF1976D2,
          isDefault: true,
        ),
        const JournalCategory(
          id: 'cat_other',
          name: 'Autres',
          nameEn: 'Other',
          iconCode: 0xe148, // Icons.category_rounded
          colorValue: 0xFF78909C,
          isDefault: true,
        ),
      ];
}

