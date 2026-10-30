import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/intima_card.dart';
import '../../encounters/providers/encounters_provider.dart';
import '../providers/partners_provider.dart';

class PartnerDetailScreen extends ConsumerWidget {
  const PartnerDetailScreen({super.key, required this.partnerId});

  final String partnerId;

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.commonWarning),
        content: Text(l10n.partnerDeleteWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Anonymiser les rencontres
              await ref.read(encountersProvider.notifier).deleteEncounter('');
              await ref.read(partnersProvider.notifier).deletePartner(partnerId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.toastDeleted)),
                );
                context.pop();
              }
            },
            child: Text(l10n.partnerDeleteKeepData),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              // Supprimer le partenaire
              await ref.read(partnersProvider.notifier).deletePartner(partnerId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.toastDeleted)),
                );
                context.pop();
              }
            },
            child: Text(l10n.partnerDeleteAll),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final partner = ref.watch(partnersProvider.notifier).findById(partnerId);
    final encounters = ref.watch(encountersProvider.notifier).byPartner(partnerId);

    if (partner == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.commonUnknown)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(partner.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/partners/$partnerId/edit'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'archive') {
                if (partner.isArchived) {
                  await ref.read(partnersProvider.notifier).restorePartner(partnerId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.toastRestored)),
                    );
                  }
                } else {
                  await ref.read(partnersProvider.notifier).archivePartner(partnerId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.toastArchived)),
                    );
                  }
                }
              } else if (value == 'delete') {
                _showDeleteDialog(context, ref);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'archive',
                child: Text(
                  partner.isArchived ? l10n.commonRestore : l10n.commonArchive,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  l10n.commonDelete,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // En-tête profil
          Center(
            child: CircleAvatar(
              backgroundColor: Color(partner.color),
              foregroundColor: Colors.white,
              radius: 40,
              child: Text(
                partner.displayName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              partner.displayName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          if (partner.firstMetDate != null) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${l10n.partnerFirstMet} : ${du.DateUtils.formatDate(partner.firstMetDate!)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Étiquettes
          if (partner.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: partner.tags.map((t) => Chip(label: Text(t))).toList(),
              ),
            ),

          // Notes
          if (partner.notes != null && partner.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            IntimaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.partnerNotes,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(partner.notes!),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Rencontres associées
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.partnerEncounters,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${encounters.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          if (encounters.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  l10n.partnerNoEncounters,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            ...encounters.map((e) {
              return IntimaCard(
                onTap: () => context.push('/encounters/${e.id}'),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: AppColors.accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            du.DateUtils.formatDate(e.date),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            e.typeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

