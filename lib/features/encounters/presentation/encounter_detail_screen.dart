import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/intima_card.dart';
import '../../partners/providers/partners_provider.dart';
import '../providers/encounters_provider.dart';

class EncounterDetailScreen extends ConsumerWidget {
  const EncounterDetailScreen({super.key, required this.encounterId});

  final String encounterId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.commonWarning),
        content: Text(l10n.encounterDeleteWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(encountersProvider.notifier).deleteEncounter(encounterId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.toastDeleted)),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final encounters = ref.watch(encountersProvider).valueOrNull ?? [];
    final encounter = encounters.where((e) => e.id == encounterId).firstOrNull;

    if (encounter == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.commonUnknown)),
      );
    }

    final partner = encounter.partnerId != null
        ? ref.read(partnersProvider.notifier).findById(encounter.partnerId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.encounterDetail),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/encounters/$encounterId/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            du.DateUtils.formatDate(encounter.date),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            encounter.typeLabel,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (partner != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.encounterPartner} : ${partner.displayName}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
                if (encounter.durationMinutes != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n.encounterDuration} : ${encounter.durationMinutes} min',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          if (encounter.notes != null && encounter.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            IntimaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.encounterNotes,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(encounter.notes!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

