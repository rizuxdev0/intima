import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/illustrations/intima_illustrations.dart';
import '../domain/models/journal_category.dart';
import '../providers/journal_categories_provider.dart';
import '../providers/journal_provider.dart';
import '../../settings/providers/preferences_provider.dart';
import 'journal_calendar_screen.dart';
import 'journal_reminders_screen.dart';
import 'journal_stats_screen.dart';
import 'widgets/journal_entry_card.dart';
import 'widgets/journal_filter_sheet.dart';

/// Écran principal du Module Journal Intime (Cahier des charges v1.0).
///
/// Intègre 4 espaces d'expérience :
/// 1. Écrits (Chronologie, filtres multicritères, recherche réactive)
/// 2. Calendrier (Navigation mensuelle, aperçu par date)
/// 3. Statistiques (Séries consécutives, évolution émotionnelle, répartition)
/// 4. Rappels (Notifications locales discrètes programmées)
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const JournalFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final prefsAsync = ref.watch(preferencesProvider);
    final isDiscreet = prefsAsync.valueOrNull?.discreetMode == true;

    final filteredEntries = ref.watch(journalFilteredEntriesProvider);
    final categoriesAsync = ref.watch(journalCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? JournalCategory.defaultCategories;

    final hasActiveFilter = ref.watch(journalSelectedMoodFilterProvider) != null ||
        ref.watch(journalSelectedCategoryFilterProvider) != null ||
        ref.watch(journalSelectedTagFilterProvider) != null ||
        ref.watch(journalFavoriteOnlyFilterProvider) ||
        ref.watch(journalShowArchivedFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: locale == 'en' ? 'Search journal...' : 'Rechercher une pensée...',
                  border: InputBorder.none,
                ),
                onChanged: (q) =>
                    ref.read(journalSearchQueryProvider.notifier).state = q,
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    locale == 'en' ? 'Intimate Journal' : 'Journal Intime',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        actions: [
          // Recherche
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  ref.read(journalSearchQueryProvider.notifier).state = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          // Filtres
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: _openFilterSheet,
              ),
              if (hasActiveFilter)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: locale == 'en' ? 'Entries' : 'Écrits'),
            Tab(text: locale == 'en' ? 'Calendar' : 'Calendrier'),
            Tab(text: locale == 'en' ? 'Insights' : 'Statistiques'),
            Tab(text: locale == 'en' ? 'Reminders' : 'Rappels'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ─── Onglet 1 : Liste des écrits ────────────────────────────────────
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(journalEntriesProvider),
            child: filteredEntries.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const IntimaAnimatedIllustration(
                            type: IntimaIllustrationType.journal,
                            size: 140,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            locale == 'en' ? 'Your sacred private space' : 'Votre espace intime et secret',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            locale == 'en'
                                ? 'No writing matches your filters. Write freely what is on your heart, totally offline and encrypted.'
                                : 'Aucun écrit ne correspond à vos filtres. Notez vos émotions, souvenirs et pensées en toute liberté, 100% hors ligne et chiffré.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.edit_note_rounded),
                            label: Text(locale == 'en' ? 'Write my first entry' : 'Rédiger une pensée'),
                            onPressed: () => context.push(AppRoutes.journalNew),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 84),
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      final cat = categories.cast<JournalCategory?>().firstWhere(
                            (c) => c?.id == entry.categoryId,
                            orElse: () => null,
                          );
                      return JournalEntryCard(
                        entry: entry,
                        category: cat,
                        isDiscreet: isDiscreet,
                        onTap: () => context.push('${AppRoutes.journal}/${entry.id}'),
                        onFavoriteToggle: () => ref
                            .read(journalEntriesProvider.notifier)
                            .toggleFavorite(entry.id),
                      );
                    },
                  ),
          ),

          // ─── Onglet 2 : Calendrier ─────────────────────────────────────────
          const JournalCalendarScreen(),

          // ─── Onglet 3 : Statistiques & Émotions ────────────────────────────
          const JournalStatsScreen(),

          // ─── Onglet 4 : Rappels programmés ─────────────────────────────────
          const JournalRemindersScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.edit_rounded),
        label: Text(locale == 'en' ? 'Write' : 'Écrire'),
        onPressed: () => context.push(AppRoutes.journalNew),
      ),
    );
  }
}

