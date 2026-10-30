import 'package:flutter/material.dart';

/// Catégories de résultats pour la recherche globale déchiffrée en mémoire.
enum SearchCategory {
  all,
  partner,
  encounter,
  journal,
  guide,
  screening,
}

extension SearchCategoryExtension on SearchCategory {
  String get label {
    switch (this) {
      case SearchCategory.all:
        return 'Tous';
      case SearchCategory.partner:
        return 'Partenaires';
      case SearchCategory.encounter:
        return 'Rencontres';
      case SearchCategory.journal:
        return 'Journal';
      case SearchCategory.guide:
        return 'Guides & Santé';
      case SearchCategory.screening:
        return 'Dépistages IST';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchCategory.all:
        return Icons.search_rounded;
      case SearchCategory.partner:
        return Icons.people_rounded;
      case SearchCategory.encounter:
        return Icons.favorite_rounded;
      case SearchCategory.journal:
        return Icons.book_rounded;
      case SearchCategory.guide:
        return Icons.lightbulb_rounded;
      case SearchCategory.screening:
        return Icons.health_and_safety_rounded;
    }
  }
}

/// Modèle unifié d'un résultat de recherche Spotlight local.
class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.route,
    required this.icon,
    required this.iconColor,
    this.date,
    this.badge,
    this.highlightSnippet,
  });

  final String id;
  final String title;
  final String subtitle;
  final SearchCategory category;
  final String route;
  final IconData icon;
  final Color iconColor;
  final DateTime? date;
  final String? badge;
  final String? highlightSnippet;
}

