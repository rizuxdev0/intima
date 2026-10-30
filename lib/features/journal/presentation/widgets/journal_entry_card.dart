import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/intima_card.dart';
import '../../domain/models/journal_category.dart';
import '../../domain/models/journal_entry.dart';

/// Carte de présentation d'une entrée de journal dans la liste.
class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    super.key,
    required this.entry,
    this.category,
    required this.onTap,
    this.onFavoriteToggle,
    this.isDiscreet = false,
  });

  final JournalEntry entry;
  final JournalCategory? category;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isDiscreet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('EEEE d MMMM yyyy', locale);
    final timeFormat = DateFormat('HH:mm');

    final catColor = category?.color ?? AppColors.primary;
    final catName = category?.localizedName(locale) ?? 'Général';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: IntimaCard(
        onTap: onTap,
        borderColor: entry.isFavorite
            ? AppColors.primary.withValues(alpha: 0.4)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : Date, Humeur, Épinglé
            Row(
              children: [
                // Pastille d'humeur
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: entry.mood.color.withValues(alpha: isDark ? 0.25 : 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.mood.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        locale == 'en' ? entry.mood.labelEn : entry.mood.labelFr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: entry.mood.color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Indicateur discret d'intensité
                      Row(
                        children: List.generate(
                          entry.moodIntensity,
                          (i) => Container(
                            margin: const EdgeInsets.only(left: 2),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: entry.mood.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Indicateur de brouillon si applicable
                if (entry.isDraft)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Brouillon',
                      style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),

                // Épinglé / Favori
                if (onFavoriteToggle != null)
                  IconButton(
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      entry.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                      color: entry.isFavorite ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    onPressed: onFavoriteToggle,
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Titre de l'entrée
            Text(
              isDiscreet ? '••••••••••••••••••••' : entry.displayTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // Extrait du contenu
            Text(
              isDiscreet
                  ? 'Contenu masqué en mode discret. Touchez pour déverrouiller la vue.'
                  : entry.previewSnippet,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Pied de carte : Catégorie, Photos et Date
            Row(
              children: [
                // Badge catégorie
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category?.icon ?? Icons.folder_rounded, size: 12, color: catColor),
                      const SizedBox(width: 4),
                      Text(
                        catName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: catColor,
                        ),
                      ),
                    ],
                  ),
                ),

                if (entry.attachments.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.image_outlined, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.attachments.length}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Date et heure
                Text(
                  '${dateFormat.format(entry.date)} • ${timeFormat.format(entry.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

