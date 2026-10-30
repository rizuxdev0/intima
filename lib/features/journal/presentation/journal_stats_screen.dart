import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/intima_card.dart';
import '../domain/models/journal_category.dart';
import '../providers/journal_categories_provider.dart';
import '../providers/journal_stats_provider.dart';

/// Écran des statistiques et de l'évolution émotionnelle du Journal Intime.
class JournalStatsScreen extends ConsumerWidget {
  const JournalStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = theme.brightness == Brightness.dark;

    final stats = ref.watch(journalStatsProvider);
    final categoriesAsync = ref.watch(journalCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? JournalCategory.defaultCategories;

    return Scaffold(
      body: stats.totalEntries == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_graph_rounded, size: 54, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      locale == 'en' ? 'No statistics yet' : 'Pas encore de statistiques',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      locale == 'en'
                          ? 'Write your first thoughts to discover your mood patterns and writing streaks.'
                          : 'Rédigez vos premières pensées pour découvrir la répartition de vos émotions et vos séries d\'écriture.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Carte Série d'écriture (Streak)
                IntimaCard(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.08),
                  borderColor: AppColors.primary.withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🔥', style: TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locale == 'en' ? 'Writing Streak' : 'Série d\'écriture',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${stats.currentStreak} ${locale == 'en' ? 'consecutive days' : 'jours consécutifs'}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stats.currentStreak >= 3
                                  ? (locale == 'en'
                                      ? 'Incredible consistency! Keep taking care of yourself.'
                                      : 'Superbe régularité ! Continuez à prendre ce temps pour vous.')
                                  : (locale == 'en'
                                      ? 'Write today to build your streak.'
                                      : 'Écrivez aujourd\'hui pour prolonger votre série.'),
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Grille 3 chiffres clés
                Row(
                  children: [
                    Expanded(
                      child: IntimaCard(
                        child: Column(
                          children: [
                            const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(height: 6),
                            Text(
                              '${stats.totalEntries}',
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              locale == 'en' ? 'Total entries' : 'Total écrits',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: IntimaCard(
                        child: Column(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: AppColors.accent, size: 22),
                            const SizedBox(height: 6),
                            Text(
                              '${stats.entriesThisMonth}',
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              locale == 'en' ? 'This month' : 'Ce mois-ci',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: IntimaCard(
                        child: Column(
                          children: [
                            const Icon(Icons.edit_note_rounded, color: Color(0xFF388E6C), size: 22),
                            const SizedBox(height: 6),
                            Text(
                              '${stats.totalWordsWritten}',
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              locale == 'en' ? 'Words written' : 'Mots rédigés',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Distribution des émotions (Graphique circulaire)
                IntimaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pie_chart_outline_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            locale == 'en' ? 'Emotional Balance' : 'Répartition des émotions',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 42,
                            sections: stats.moodDistribution.entries.map((entry) {
                              final mood = entry.key;
                              final count = entry.value;
                              final pct = (count / stats.totalEntries * 100).round();
                              return PieChartSectionData(
                                color: mood.color,
                                value: count.toDouble(),
                                title: '$pct%',
                                radius: 46,
                                titleStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Légende des émotions
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: stats.moodDistribution.entries.map((entry) {
                          final mood = entry.key;
                          final count = entry.value;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: mood.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text('${mood.emoji} ${locale == 'en' ? mood.labelEn : mood.labelFr} ($count)'),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Catégories les plus actives
                IntimaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.category_outlined, color: AppColors.accent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            locale == 'en' ? 'Top Categories' : 'Catégories les plus actives',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...stats.categoryCounts.entries.map((e) {
                        final cat = categories.cast<JournalCategory?>().firstWhere(
                              (c) => c?.id == e.key,
                              orElse: () => null,
                            );
                        final name = cat?.localizedName(locale) ?? e.key;
                        final count = e.value;
                        final pct = (count / stats.totalEntries).clamp(0.0, 1.0);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(cat?.icon ?? Icons.folder_rounded, size: 14, color: cat?.color ?? AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const Spacer(),
                                  Text('$count ${locale == 'en' ? 'entries' : 'écrits'}', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 6,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(cat?.color ?? AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }
}

