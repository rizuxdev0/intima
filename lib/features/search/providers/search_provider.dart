import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../education/data/education_repository.dart';
import '../../encounters/providers/encounters_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../../partners/providers/partners_provider.dart';
import '../../sexual_health/providers/sexual_health_provider.dart';
import '../domain/models/search_result_item.dart';

/// Requête textuelle active de la recherche globale.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtre actif par catégorie.
final searchCategoryFilterProvider = StateProvider<SearchCategory>((ref) => SearchCategory.all);

/// Moteur de recherche globale unifié : interroge en mémoire vive l'ensemble
/// des collections locales déchiffrées pour un résultat instantané sans latence.
final globalSearchResultsProvider = Provider<List<SearchResultItem>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final selectedCategory = ref.watch(searchCategoryFilterProvider);

  final partners = ref.watch(partnersProvider).valueOrNull ?? [];
  final encounters = ref.watch(encountersProvider).valueOrNull ?? [];
  final journalEntries = ref.watch(journalEntriesProvider).valueOrNull ?? [];
  final sexualHealth = ref.watch(sexualHealthProvider).valueOrNull;
  final guides = EducationRepository.defaultCatalog;

  final partnersMap = {for (final p in partners) p.id: p};
  final results = <SearchResultItem>[];

  final tokens = query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

  bool matchesTokens(String text) {
    if (tokens.isEmpty) return true;
    final lower = text.toLowerCase();
    return tokens.every((token) => lower.contains(token));
  }

  // ─── 1. Recherche Partenaires ───────────────────────────────────────────────
  if (selectedCategory == SearchCategory.all || selectedCategory == SearchCategory.partner) {
    for (final partner in partners) {
      if (partner.isArchived) continue;
      final searchableText = '${partner.displayName} ${partner.notes ?? ''} ${partner.tags.join(' ')}';
      if (matchesTokens(searchableText)) {
        results.add(
          SearchResultItem(
            id: 'partner_${partner.id}',
            title: partner.displayName,
            subtitle: partner.notes?.isNotEmpty == true
                ? partner.notes!
                : (partner.tags.isNotEmpty ? partner.tags.join(' • ') : 'Fiche partenaire'),
            category: SearchCategory.partner,
            route: '${AppRoutes.partners}/${partner.id}',
            icon: Icons.person_rounded,
            iconColor: partner.colorValue,
            badge: partner.tags.isNotEmpty ? partner.tags.first : null,
          ),
        );
      }
    }
  }

  // ─── 2. Recherche Rencontres Intimes ────────────────────────────────────────
  if (selectedCategory == SearchCategory.all || selectedCategory == SearchCategory.encounter) {
    for (final encounter in encounters) {
      final partnerName = encounter.partnerId != null ? (partnersMap[encounter.partnerId]?.displayName ?? '') : '';
      final searchableText = '$partnerName ${encounter.typeLabel} ${encounter.notes ?? ''} ${encounter.tags.join(' ')}';
      if (matchesTokens(searchableText)) {
        results.add(
          SearchResultItem(
            id: 'encounter_${encounter.id}',
            title: partnerName.isNotEmpty ? 'Rencontre avec $partnerName' : encounter.typeLabel,
            subtitle: encounter.notes?.isNotEmpty == true
                ? encounter.notes!
                : du.DateUtils.formatDate(encounter.date),
            category: SearchCategory.encounter,
            route: '${AppRoutes.encounters}/${encounter.id}',
            icon: Icons.favorite_rounded,
            iconColor: AppColors.accent,
            date: encounter.date,
            badge: encounter.typeLabel,
          ),
        );
      }
    }
  }

  // ─── 3. Recherche Journal Intime ───────────────────────────────────────────
  if (selectedCategory == SearchCategory.all || selectedCategory == SearchCategory.journal) {
    for (final entry in journalEntries) {
      if (entry.isArchived) continue;
      final searchableText = '${entry.title ?? ''} ${entry.content} ${entry.tags.join(' ')} ${entry.notes ?? ''} ${entry.mood.labelFr}';
      if (matchesTokens(searchableText)) {
        results.add(
          SearchResultItem(
            id: 'journal_${entry.id}',
            title: entry.displayTitle,
            subtitle: entry.content.length > 80 ? '${entry.content.substring(0, 80)}...' : entry.content,
            category: SearchCategory.journal,
            route: '${AppRoutes.journal}/${entry.id}',
            icon: Icons.edit_note_rounded,
            iconColor: const Color(0xFF7E57C2),
            date: entry.date,
            badge: entry.mood.labelFr,
          ),
        );
      }
    }
  }

  // ─── 4. Recherche Fiches & Guides Médicaux ─────────────────────────────────
  if (selectedCategory == SearchCategory.all || selectedCategory == SearchCategory.guide) {
    for (final guide in guides) {
      final searchableText = '${guide.title} ${guide.subtitle} ${guide.category.labelFr} ${guide.tags.join(' ')} ${guide.keyTakeaways.join(' ')}';
      if (matchesTokens(searchableText)) {
        results.add(
          SearchResultItem(
            id: 'guide_${guide.id}',
            title: guide.title,
            subtitle: guide.subtitle,
            category: SearchCategory.guide,
            route: '${AppRoutes.education}/${guide.id}',
            icon: Icons.lightbulb_rounded,
            iconColor: const Color(0xFFE5A93C),
            badge: '${guide.readingTimeMinutes} min',
          ),
        );
      }
    }
  }

  // ─── 5. Recherche Santé Sexuelle & Dépistages ───────────────────────────────
  if (selectedCategory == SearchCategory.all || selectedCategory == SearchCategory.screening) {
    if (sexualHealth != null) {
      for (final screening in sexualHealth.screenings) {
        final lab = screening.laboratoryOrClinic?.isNotEmpty == true
            ? screening.laboratoryOrClinic!
            : 'Bilan de dépistage IST';
        final testList = screening.testedStis.join(', ');
        final searchableText = '$lab $testList ${screening.notes ?? ''}';
        if (matchesTokens(searchableText)) {
          results.add(
            SearchResultItem(
              id: 'screening_${screening.id}',
              title: lab,
              subtitle: '$testList • ${du.DateUtils.formatDate(screening.date)}',
              category: SearchCategory.screening,
              route: AppRoutes.sexualHealth,
              icon: Icons.health_and_safety_rounded,
              iconColor: const Color(0xFF2D5A46),
              date: screening.date,
              badge: screening.status.labelFr,
            ),
          );
        }
      }
    }
  }

  return results;
});
