import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/intima_card.dart';
import '../domain/models/educational_guide.dart';
import '../providers/education_provider.dart';

/// Hub éducatif et pédagogique : Fiches Bien-être & Santé Intime hors ligne.
class EducationHubScreen extends ConsumerStatefulWidget {
  const EducationHubScreen({super.key});

  @override
  ConsumerState<EducationHubScreen> createState() => _EducationHubScreenState();
}

class _EducationHubScreenState extends ConsumerState<EducationHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(selectedGuideCategoryProvider);
    final filteredGuides = ref.watch(filteredGuidesProvider);
    final favoritesAsync = ref.watch(guideFavoritesProvider);
    final favoriteIds = favoritesAsync.valueOrNull ?? <String>{};

    final displayedGuides = _showFavoritesOnly
        ? filteredGuides.where((g) => favoriteIds.contains(g.id)).toList()
        : filteredGuides;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide & Fiches Bien-être'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _showFavoritesOnly ? 'Afficher tout' : 'Afficher mes favoris',
            icon: Icon(
              _showFavoritesOnly ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _showFavoritesOnly ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() => _showFavoritesOnly = !_showFavoritesOnly);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche locale
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une fiche, un symptôme, une IST...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(guidesSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                ref.read(guidesSearchQueryProvider.notifier).state = val;
              },
            ),
          ),

          // Sélecteur horizontal de catégories
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(
                  label: 'Tous (${ref.watch(allGuidesProvider).length})',
                  isSelected: selectedCategory == null && !_showFavoritesOnly,
                  onTap: () {
                    setState(() => _showFavoritesOnly = false);
                    ref.read(selectedGuideCategoryProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: '⭐ Favoris (${favoriteIds.length})',
                  isSelected: _showFavoritesOnly,
                  activeColor: Colors.amber,
                  onTap: () {
                    setState(() => _showFavoritesOnly = true);
                  },
                ),
                const SizedBox(width: 8),
                ...GuideCategory.values.map((cat) {
                  final isSelected = selectedCategory == cat && !_showFavoritesOnly;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      label: '${cat.emoji} ${cat.labelFr}',
                      isSelected: isSelected,
                      activeColor: cat.color,
                      onTap: () {
                        setState(() => _showFavoritesOnly = false);
                        ref.read(selectedGuideCategoryProvider.notifier).state = cat;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Liste des fiches pédagogiques
          Expanded(
            child: displayedGuides.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showFavoritesOnly
                                ? Icons.star_border_rounded
                                : Icons.search_off_rounded,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showFavoritesOnly
                                ? 'Aucune fiche dans vos favoris.\nTouchez l\'étoile sur une fiche pour l\'enregistrer.'
                                : 'Aucune fiche trouvée pour cette recherche.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: displayedGuides.length,
                    itemBuilder: (context, index) {
                      final guide = displayedGuides[index];
                      final isFav = favoriteIds.contains(guide.id);

                      return _GuideCard(
                        guide: guide,
                        isFavorite: isFav,
                        onTap: () => context.push('${AppRoutes.education}/${guide.id}'),
                        onToggleFavorite: () {
                          ref.read(guideFavoritesProvider.notifier).toggleFavorite(guide.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.25),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte représentant un guide dans la liste.
class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.guide,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final EducationalGuide guide;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catColor = guide.category.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntimaCard(
        onTap: onTap,
        borderColor: catColor.withValues(alpha: 0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Emoji dans un container arrondi
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(guide.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          guide.category.labelFr,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                          ),
                        ),
                      ),
                      Text(
                        '⏱️ ${guide.readingTimeMinutes} min de lecture',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFavorite ? Colors.amber : Colors.grey,
                    size: 22,
                  ),
                  tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                  onPressed: onToggleFavorite,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              guide.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              guide.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.35,
              ),
            ),
            if (guide.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: guide.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

