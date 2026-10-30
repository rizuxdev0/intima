import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/models/journal_category.dart';
import '../../domain/models/journal_mood.dart';
import '../../providers/journal_categories_provider.dart';
import '../../providers/journal_provider.dart';

/// Feuille modale pour le filtrage avancé des entrées du journal.
class JournalFilterSheet extends ConsumerWidget {
  const JournalFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final selectedMood = ref.watch(journalSelectedMoodFilterProvider);
    final selectedCategory = ref.watch(journalSelectedCategoryFilterProvider);
    final favoriteOnly = ref.watch(journalFavoriteOnlyFilterProvider);
    final showArchived = ref.watch(journalShowArchivedFilterProvider);

    final categoriesAsync = ref.watch(journalCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? JournalCategory.defaultCategories;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                locale == 'en' ? 'Filter Journal' : 'Filtrer le Journal',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(journalSelectedMoodFilterProvider.notifier).state = null;
                  ref.read(journalSelectedCategoryFilterProvider.notifier).state = null;
                  ref.read(journalSelectedTagFilterProvider.notifier).state = null;
                  ref.read(journalFavoriteOnlyFilterProvider.notifier).state = false;
                  ref.read(journalShowArchivedFilterProvider.notifier).state = false;
                },
                child: Text(locale == 'en' ? 'Reset' : 'Réinitialiser'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filtre Humeur
          Text(
            locale == 'en' ? 'By Emotion / Mood' : 'Par Émotion / Humeur',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(locale == 'en' ? 'All' : 'Toutes'),
                  selected: selectedMood == null,
                  onSelected: (_) =>
                      ref.read(journalSelectedMoodFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                ...JournalMoodType.values.map((mood) {
                  final isSelected = mood == selectedMood;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Text(mood.emoji),
                      label: Text(locale == 'en' ? mood.labelEn : mood.labelFr),
                      selected: isSelected,
                      selectedColor: mood.color.withValues(alpha: 0.25),
                      onSelected: (val) {
                        ref.read(journalSelectedMoodFilterProvider.notifier).state =
                            val ? mood : null;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filtre Catégorie
          Text(
            locale == 'en' ? 'By Category' : 'Par Catégorie',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(locale == 'en' ? 'All' : 'Toutes'),
                  selected: selectedCategory == null,
                  onSelected: (_) =>
                      ref.read(journalSelectedCategoryFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                ...categories.map((cat) {
                  final isSelected = cat.id == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(cat.icon, size: 14, color: cat.color),
                      label: Text(cat.localizedName(locale)),
                      selected: isSelected,
                      selectedColor: cat.color.withValues(alpha: 0.25),
                      onSelected: (val) {
                        ref.read(journalSelectedCategoryFilterProvider.notifier).state =
                            val ? cat.id : null;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Interrupteurs Favoris et Archives
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(locale == 'en' ? 'Favorites only' : 'Favoris uniquement'),
            secondary: const Icon(Icons.favorite_rounded, color: AppColors.primary),
            value: favoriteOnly,
            onChanged: (val) =>
                ref.read(journalFavoriteOnlyFilterProvider.notifier).state = val,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(locale == 'en' ? 'Show archived entries' : 'Afficher les écrits archivés'),
            secondary: const Icon(Icons.archive_outlined),
            value: showArchived,
            onChanged: (val) =>
                ref.read(journalShowArchivedFilterProvider.notifier).state = val,
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(locale == 'en' ? 'Apply Filters' : 'Appliquer les filtres'),
            ),
          ),
        ],
      ),
    );
  }
}

