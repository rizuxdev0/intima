import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../domain/models/journal_category.dart';
import '../domain/models/journal_entry.dart';
import '../providers/journal_categories_provider.dart';
import '../providers/journal_provider.dart';

/// Vue détaillée et immersive d'un écrit du Journal Intime.
class JournalDetailScreen extends ConsumerWidget {
  const JournalDetailScreen({
    super.key,
    required this.entryId,
  });

  final String entryId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette entrée ?'),
        content: const Text(
          'Cette action est irréversible. L\'écrit sera définitivement supprimé de votre stockage chiffré.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(journalEntriesProvider.notifier).deleteEntry(entryId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entrée supprimée du journal.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    }
  }

  void _shareEntry(JournalEntry entry) {
    final text = 'INTIMA Journal - ${entry.displayTitle}\n\n'
        'Date : ${DateFormat('dd/MM/yyyy HH:mm').format(entry.date)}\n'
        'Émotion : ${entry.mood.emoji} ${entry.mood.labelFr}\n\n'
        '${entry.content}';
    Share.share(text, subject: entry.displayTitle);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('EEEE d MMMM yyyy à HH:mm', locale);

    final entriesAsync = ref.watch(journalEntriesProvider);
    final entries = entriesAsync.valueOrNull ?? [];
    final entry = entries.cast<JournalEntry?>().firstWhere(
          (e) => e?.id == entryId,
          orElse: () => null,
        );

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Cette entrée n\'existe plus.')),
      );
    }

    final categoriesAsync = ref.watch(journalCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? JournalCategory.defaultCategories;
    final category = categories.cast<JournalCategory?>().firstWhere(
          (c) => c?.id == entry.categoryId,
          orElse: () => null,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale == 'en' ? 'Journal Entry' : 'Écrit intime',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              entry.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              color: entry.isFavorite ? AppColors.primary : null,
            ),
            tooltip: 'Favori',
            onPressed: () =>
                ref.read(journalEntriesProvider.notifier).toggleFavorite(entry.id),
          ),
          PopupMenuButton<String>(
            onSelected: (val) async {
              switch (val) {
                case 'edit':
                  context.push('${AppRoutes.journal}/${entry.id}/edit');
                  break;
                case 'duplicate':
                  final dup = await ref
                      .read(journalEntriesProvider.notifier)
                      .duplicateEntry(entry.id);
                  if (context.mounted && dup != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entrée dupliquée avec succès.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  break;
                case 'archive':
                  await ref
                      .read(journalEntriesProvider.notifier)
                      .setArchived(entry.id, !entry.isArchived);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(entry.isArchived
                            ? 'Entrée rétablie du dossier archive.'
                            : 'Entrée archivée.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                  break;
                case 'share':
                  _shareEntry(entry);
                  break;
                case 'delete':
                  _confirmDelete(context, ref);
                  break;
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(locale == 'en' ? 'Edit' : 'Modifier'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    const Icon(Icons.copy_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(locale == 'en' ? 'Duplicate' : 'Dupliquer'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(entry.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(entry.isArchived
                        ? (locale == 'en' ? 'Unarchive' : 'Désarchiver')
                        : (locale == 'en' ? 'Archive' : 'Archiver')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(Icons.share_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(locale == 'en' ? 'Share text' : 'Partager le texte'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text(
                      locale == 'en' ? 'Delete' : 'Supprimer',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bandeau d'humeur & catégorie
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: entry.mood.color.withValues(alpha: isDark ? 0.3 : 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.mood.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        locale == 'en' ? entry.mood.labelEn : entry.mood.labelFr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: entry.mood.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${entry.moodIntensity}/5)',
                        style: TextStyle(
                          fontSize: 12,
                          color: entry.mood.color.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (category != null)
                  Chip(
                    avatar: Icon(category.icon, size: 14, color: category.color),
                    label: Text(
                      category.localizedName(locale),
                      style: TextStyle(color: category.color, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    backgroundColor: category.color.withValues(alpha: 0.12),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // Date complète
            Text(
              dateFormat.format(entry.date),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 16),

            // Titre
            if (entry.title != null && entry.title!.isNotEmpty) ...[
              Text(
                entry.title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Divider(),

            const SizedBox(height: 16),

            // Contenu textuel rédigé
            SelectableText(
              entry.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.7,
                fontSize: 16,
              ),
            ),

            // Tags
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.tags
                    .map(
                      (tag) => Chip(
                        label: Text('#$tag'),
                        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      ),
                    )
                    .toList(),
              ),
            ],

            // Photos attachées
            if (entry.attachments.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text(
                locale == 'en' ? 'Attached Photos' : 'Photos attachées',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entry.attachments.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final att = entry.attachments[i];
                    return Container(
                      width: 130,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_rounded, size: 36, color: AppColors.primary),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              att.fileName,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 48),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded),
        label: Text(locale == 'en' ? 'Edit' : 'Modifier'),
        onPressed: () => context.push('${AppRoutes.journal}/${entry.id}/edit'),
      ),
    );
  }
}

