import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/app_preferences.dart';
import '../../encounters/providers/encounters_provider.dart';
import '../../settings/providers/preferences_provider.dart';
import '../domain/cycle_calculation_engine.dart';
import '../providers/menstrual_cycle_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDay;

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final prefs = ref.watch(preferencesProvider).valueOrNull ?? const AppPreferences();
    final cycles = ref.watch(menstrualCycleProvider).valueOrNull ?? [];
    final encounters = ref.watch(encountersProvider).valueOrNull ?? [];
    final prediction = ref.watch(cyclePredictionProvider);

    final hasCycle = prefs.hasMenstrualTracking;

    // Préparation des ensembles de dates
    final periodDays = <DateTime>{};
    if (hasCycle) {
      for (final cycle in cycles) {
        final start = cycle.startDate;
        final end = cycle.endDate ?? start.add(const Duration(days: 4));
        var d = start;
        while (!d.isAfter(end)) {
          periodDays.add(DateTime(d.year, d.month, d.day));
          d = d.add(const Duration(days: 1));
        }
      }
    }

    final estimatedDays = (hasCycle && prediction != null)
        ? CycleCalculationEngine.estimatedPeriodDays(
            prediction,
            _currentMonth.year,
            _currentMonth.month,
          )
        : <DateTime>{};

    final fertileDays = (hasCycle && prediction != null)
        ? CycleCalculationEngine.fertileDaysInMonth(
            prediction,
            _currentMonth.year,
            _currentMonth.month,
          )
        : <DateTime>{};

    final encounterDays = encounters.map((e) {
      return DateTime(e.date.year, e.date.month, e.date.day);
    }).toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_outlined),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // En-tête mois + flèches
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _previousMonth,
                ),
                Text(
                  '${du.DateUtils.monthName(_currentMonth.month, locale: prefs.locale)} ${_currentMonth.year}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Grille du calendrier
          _CalendarGrid(
            month: _currentMonth,
            selectedDay: _selectedDay,
            periodDays: periodDays,
            estimatedPeriodDays: estimatedDays,
            fertileDays: fertileDays,
            encounterDays: encounterDays,
            weekStartsOnMonday: prefs.weekStartsOnMonday,
            onDaySelected: (day) {
              setState(() => _selectedDay = day);
            },
          ),

          const SizedBox(height: 12),

          // Légende accessible
          _CalendarLegend(l10n: l10n, hasCycle: hasCycle),

          const SizedBox(height: 16),

          // Événements du jour sélectionné
          if (_selectedDay != null)
            _SelectedDayDetails(
              selectedDay: _selectedDay!,
              encounters: encounters.where((e) {
                return du.DateUtils.isSameDay(e.date, _selectedDay!);
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selectedDay,
    required this.periodDays,
    required this.estimatedPeriodDays,
    required this.fertileDays,
    required this.encounterDays,
    required this.weekStartsOnMonday,
    required this.onDaySelected,
  });

  final DateTime month;
  final DateTime? selectedDay;
  final Set<DateTime> periodDays;
  final Set<DateTime> estimatedPeriodDays;
  final Set<DateTime> fertileDays;
  final Set<DateTime> encounterDays;
  final bool weekStartsOnMonday;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    var startOffset = firstDay.weekday - (weekStartsOnMonday ? 1 : 0);
    if (startOffset < 0) startOffset += 7;

    final weekDays = weekStartsOnMonday
        ? ['L', 'M', 'M', 'J', 'V', 'S', 'D']
        : ['D', 'L', 'M', 'M', 'J', 'V', 'S'];

    return IntimaCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((d) {
              return SizedBox(
                width: 36,
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startOffset + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < startOffset) {
                return const SizedBox.shrink();
              }
              final dayNum = index - startOffset + 1;
              final dayDate = DateTime(month.year, month.month, dayNum);

              final isSelected = selectedDay != null &&
                  du.DateUtils.isSameDay(selectedDay!, dayDate);
              final isToday = du.DateUtils.isToday(dayDate);
              final isPeriod = periodDays.contains(dayDate);
              final isEstimatedPeriod = estimatedPeriodDays.contains(dayDate);
              final isFertile = fertileDays.contains(dayDate);
              final hasEncounter = encounterDays.contains(dayDate);

              Color? bg;
              if (isSelected) {
                bg = AppColors.primary;
              } else if (isPeriod) {
                bg = AppColors.calendarPeriod.withValues(alpha: 0.8);
              } else if (isEstimatedPeriod) {
                bg = AppColors.calendarEstimatedPeriod.withValues(alpha: 0.5);
              } else if (isFertile) {
                bg = AppColors.calendarFertile.withValues(alpha: 0.4);
              }

              return InkWell(
                onTap: () => onDaySelected(dayDate),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: isToday
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isPeriod ? Colors.white : null),
                        ),
                      ),
                      if (hasEncounter)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.calendarEncounter,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.l10n, required this.hasCycle});

  final AppLocalizations l10n;
  final bool hasCycle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          if (hasCycle) ...[
            _LegendItem(color: AppColors.calendarPeriod, label: l10n.calendarLegendPeriod),
            _LegendItem(color: AppColors.calendarEstimatedPeriod, label: l10n.calendarLegendEstimated),
            _LegendItem(color: AppColors.calendarFertile, label: l10n.calendarLegendFertile),
          ],
          _LegendItem(color: AppColors.calendarEncounter, label: l10n.calendarLegendEncounter, isDot: true),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.isDot = false,
  });

  final Color color;
  final String label;
  final bool isDot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isDot ? 8 : 12,
          height: isDot ? 8 : 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _SelectedDayDetails extends StatelessWidget {
  const _SelectedDayDetails({
    required this.selectedDay,
    required this.encounters,
  });

  final DateTime selectedDay;
  final List<dynamic> encounters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            du.DateUtils.formatDate(selectedDay),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (encounters.isEmpty)
            Text(
              'Aucun événement enregistré ce jour.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 13,
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
                      child: Text(
                        e.typeLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

