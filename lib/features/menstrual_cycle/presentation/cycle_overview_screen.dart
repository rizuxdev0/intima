import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/intima_card.dart';
import '../providers/menstrual_cycle_provider.dart';

class CycleOverviewScreen extends ConsumerWidget {
  const CycleOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final cyclesAsync = ref.watch(menstrualCycleProvider);
    final prediction = ref.watch(cyclePredictionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cycleTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: l10n.cycleHistoryTitle,
            onPressed: () => context.push(AppRoutes.cycleHistory),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.cycleLog),
        icon: const Icon(Icons.water_drop_rounded),
        label: Text(l10n.cycleLogPeriod),
      ),
      body: cyclesAsync.when(
        data: (cycles) {
          if (cycles.isEmpty) {
            return EmptyStateView(
              icon: Icons.water_drop_outlined,
              title: l10n.cycleEmpty,
              actionLabel: l10n.cycleLogPeriod,
              onAction: () => context.push(AppRoutes.cycleLog),
            );
          }

          final latestCycle = cycles.first;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // Carte statut actuel
              IntimaCard(
                color: AppColors.calendarPeriod.withValues(alpha: 0.08),
                borderColor: AppColors.calendarPeriod.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop_rounded,
                          color: AppColors.calendarPeriod,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Dernières règles',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Début : ${du.DateUtils.formatDateLong(latestCycle.startDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (latestCycle.endDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Fin : ${du.DateUtils.formatDateLong(latestCycle.endDate!)} (${latestCycle.periodDurationDays} jours)',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Prédictions
              if (prediction != null && prediction.isReliable) ...[
                IntimaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimations indicatives',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (prediction.estimatedNextPeriodStart != null)
                        _buildPredictionRow(
                          Icons.event_available_rounded,
                          l10n.cycleNextEstimated,
                          du.DateUtils.formatDateLong(
                            prediction.estimatedNextPeriodStart!,
                          ),
                          AppColors.calendarPeriod,
                        ),
                      if (prediction.estimatedFertileWindowStart != null &&
                          prediction.estimatedFertileWindowEnd != null) ...[
                        const Divider(height: 20),
                        _buildPredictionRow(
                          Icons.eco_rounded,
                          l10n.cycleFertilityWindow,
                          '${du.DateUtils.formatDateShort(prediction.estimatedFertileWindowStart!)} - ${du.DateUtils.formatDateShort(prediction.estimatedFertileWindowEnd!)}',
                          AppColors.calendarFertile,
                        ),
                      ],
                      if (prediction.estimatedOvulationDate != null) ...[
                        const Divider(height: 20),
                        _buildPredictionRow(
                          Icons.lens_rounded,
                          l10n.cycleOvulationEstimated,
                          du.DateUtils.formatDateLong(
                            prediction.estimatedOvulationDate!,
                          ),
                          AppColors.calendarOvulation,
                        ),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                IntimaCard(
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.cycleInsufficient,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Avertissement médical obligatoire
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  l10n.cycleDisclaimer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Raccourci vers les symptômes
              IntimaCard(
                onTap: () => context.push(AppRoutes.symptomForm),
                child: Row(
                  children: [
                    const Icon(Icons.healing_rounded, color: AppColors.calendarSymptom),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.cycleSymptomsAdd,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.toastError)),
      ),
    );
  }

  Widget _buildPredictionRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

