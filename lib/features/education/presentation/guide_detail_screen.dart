import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/intima_card.dart';
import '../providers/education_provider.dart';

/// Écran de lecture immersif d'une fiche pédagogique bien-être.
class GuideDetailScreen extends ConsumerWidget {
  const GuideDetailScreen({super.key, required this.guideId});

  final String guideId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final guide = ref.watch(guideByIdProvider(guideId));
    final favoritesAsync = ref.watch(guideFavoritesProvider);
    final isFavorite = favoritesAsync.valueOrNull?.contains(guideId) ?? false;

    if (guide == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fiche introuvable')),
        body: const Center(
          child: Text('Cette fiche n\'est plus disponible.'),
        ),
      );
    }

    final catColor = guide.category.color;
    final allGuides = ref.watch(allGuidesProvider);
    final relatedGuides = allGuides
        .where((g) => g.id != guide.id && g.category == guide.category)
        .take(2)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          guide.category.labelFr,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isFavorite ? Colors.amber : null,
              size: 26,
            ),
            onPressed: () {
              ref.read(guideFavoritesProvider.notifier).toggleFavorite(guide.id);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // En-tête : Emoji + Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(guide.emoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        guide.category.labelFr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: catColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '⏱️ Lecture estimée : ${guide.readingTimeMinutes} minutes',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Titre principal & Sous-titre
          Text(
            guide.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            guide.subtitle,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Carte : Points clés à retenir (Key Takeaways)
          IntimaCard(
            color: catColor.withValues(alpha: 0.08),
            borderColor: catColor.withValues(alpha: 0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: catColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'En résumé (Points clés)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: catColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...guide.keyTakeaways.map((takeaway) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: catColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            takeaway,
                            style: const TextStyle(fontSize: 13, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sections de contenu
          ...guide.sections.map((section) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...section.paragraphs.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.88),
                        ),
                      ),
                    );
                  }),
                  if (section.bulletPoints != null) ...[
                    const SizedBox(height: 4),
                    ...section.bulletPoints!.map((bp) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Expanded(
                              child: Text(
                                bp,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  if (section.calloutText != null) ...[
                    const SizedBox(height: 10),
                    IntimaCard(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderColor: catColor.withValues(alpha: 0.3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.tips_and_updates_outlined, color: catColor, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              section.calloutText!,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Encart Relecture & Validation Médicale
          IntimaCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.success, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Relecture scientifique & médicale',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guide.medicalReviewNote,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Suggestions "À découvrir aussi"
          if (relatedGuides.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Dans la même thématique',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...relatedGuides.map((rel) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: IntimaCard(
                  onTap: () => context.pushReplacement('${AppRoutes.education}/${rel.id}'),
                  child: Row(
                    children: [
                      Text(rel.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rel.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '⏱️ ${rel.readingTimeMinutes} min de lecture',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

