import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/intima_card.dart';
import '../providers/menstrual_cycle_provider.dart';

class CycleHistoryScreen extends ConsumerWidget {
  const CycleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cycles = ref.watch(menstrualCycleProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cycleHistoryTitle),
      ),
      body: cycles.isEmpty
          ? EmptyStateView(
              icon: Icons.water_drop_outlined,
              title: l10n.cycleEmpty,
              message: 'Consignez vos règles pour débloquer les calculs de phases, la fertilité et les prévisions automatiques.',
              actionLabel: l10n.cycleLogPeriod,
              onAction: () => context.push(AppRoutes.cycleLog),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: cycles.length,
              itemBuilder: (context, index) {
                final cycle = cycles[index];
                return IntimaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            du.DateUtils.formatDate(cycle.startDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (cycle.periodDurationDays != null)
                            Chip(
                              label: Text('${cycle.periodDurationDays} jours'),
                              backgroundColor: AppColors.calendarPeriod.withValues(alpha: 0.15),
                              labelStyle: const TextStyle(
                                color: AppColors.calendarPeriod,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      if (cycle.endDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Fin : ${du.DateUtils.formatDate(cycle.endDate!)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                      if (cycle.symptoms.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${cycle.symptoms.length} symptôme(s) consigné(s)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

