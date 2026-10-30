import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/illustrations/intima_illustrations.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/app_preferences.dart';
import '../../../shared/models/encounter.dart';
import '../../partners/providers/partners_provider.dart';
import '../../settings/providers/preferences_provider.dart';
import '../providers/encounters_provider.dart';

class EncountersListScreen extends ConsumerStatefulWidget {
  const EncountersListScreen({super.key});

  @override
  ConsumerState<EncountersListScreen> createState() =>
      _EncountersListScreenState();
}

class _EncountersListScreenState extends ConsumerState<EncountersListScreen> {
  String? _selectedPartnerId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final encountersAsync = ref.watch(encountersProvider);
    final partnersAsync = ref.watch(partnersProvider);
    final prefs = ref.watch(preferencesProvider).valueOrNull ?? const AppPreferences();
    final isDiscreet = prefs.discreetMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDiscreet ? 'Journal' : l10n.encountersTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.encounterNew),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filtre par partenaire
          partnersAsync.when(
            data: (partners) {
              if (partners.isEmpty) return const SizedBox.shrink();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(l10n.commonAll),
                      selected: _selectedPartnerId == null,
                      onSelected: (_) => setState(() => _selectedPartnerId = null),
                    ),
                    const SizedBox(width: 8),
                    ...partners.map((partner) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(partner.displayName),
                          selected: _selectedPartnerId == partner.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPartnerId = selected ? partner.id : null;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          Expanded(
            child: encountersAsync.when(
              data: (encounters) {
                var filtered = encounters;
                if (_selectedPartnerId != null) {
                  filtered = filtered
                      .where((e) => e.partnerId == _selectedPartnerId)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return EmptyStateView(
                    illustrationType: IntimaIllustrationType.heart,
                    icon: Icons.favorite_border_rounded,
                    title: l10n.encountersEmpty,
                    message: 'Chaque rencontre intime consignée reste 100% confidentielle et chiffrée sur cet appareil.',
                    actionLabel: l10n.encountersAdd,
                    onAction: () => context.push(AppRoutes.encounterNew),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final encounter = filtered[index];
                    return _EncounterTile(
                      encounter: encounter,
                      isDiscreet: isDiscreet,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(child: Text(l10n.toastError)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EncounterTile extends ConsumerWidget {
  const _EncounterTile({
    required this.encounter,
    required this.isDiscreet,
  });

  final Encounter encounter;
  final bool isDiscreet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final partner = encounter.partnerId != null
        ? ref.read(partnersProvider.notifier).findById(encounter.partnerId!)
        : null;

    return IntimaCard(
      onTap: () => context.push('/encounters/${encounter.id}'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDiscreet
                      ? l10n.commonPersonalEvent
                      : (partner?.displayName ?? encounter.typeLabel),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      du.DateUtils.formatDate(encounter.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (encounter.durationMinutes != null && !isDiscreet) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${encounter.durationMinutes} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}

