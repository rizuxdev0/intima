import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../domain/models/journal_category.dart';
import '../domain/models/journal_entry.dart';
import '../providers/journal_categories_provider.dart';
import '../providers/journal_provider.dart';
import 'widgets/journal_entry_card.dart';

/// Vue Calendrier du Journal Intime selon le Cahier des Charges (Section 3.5).
class JournalCalendarScreen extends ConsumerStatefulWidget {
  const JournalCalendarScreen({super.key});

  @override
  ConsumerState<JournalCalendarScreen> createState() => _JournalCalendarScreenState();
}

class _JournalCalendarScreenState extends ConsumerState<JournalCalendarScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

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
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = theme.brightness == Brightness.dark;

    final entriesAsync = ref.watch(journalEntriesProvider);
    final allEntries = entriesAsync.valueOrNull ?? [];

    final categoriesAsync = ref.watch(journalCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? JournalCategory.defaultCategories;

    // Regrouper les entrées par jour (YYYY-MM-DD)
    final Map<String, List<JournalEntry>> entriesByDay = {};
    for (final e in allEntries) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      entriesByDay.putIfAbsent(key, () => []).add(e);
    }

    final selectedKey =
        '${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}';
    final dayEntries = entriesByDay[selectedKey] ?? [];

    // Calcul des jours du mois
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday; // 1 = Lundi
    final leadingEmpty = firstDayWeekday - 1;

    final monthTitle = DateFormat('MMMM yyyy', locale).format(_currentMonth);
    final dayHeaderFormat = DateFormat('EEEE d MMMM', locale).format(_selectedDay);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Sélecteur de mois
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        monthTitle[0].toUpperCase() + monthTitle.substring(1),
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

                  const SizedBox(height: 8),

                  // En-têtes jours de la semaine (L M M J V S D)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: (locale == 'en'
                            ? ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                            : ['L', 'M', 'M', 'J', 'V', 'S', 'D'])
                        .map(
                          (d) => SizedBox(
                            width: 36,
                            child: Center(
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 8),

                  // Grille des jours
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: leadingEmpty + daysInMonth,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      if (index < leadingEmpty) {
                        return const SizedBox.shrink();
                      }
                      final dayNum = index - leadingEmpty + 1;
                      final dayDate = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                      final key =
                          '${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}';
                      final dayHasEntries = entriesByDay.containsKey(key);
                      final dayMoods = entriesByDay[key]?.map((e) => e.mood).toSet() ?? {};
                      final isSelected = dayDate.year == _selectedDay.year &&
                          dayDate.month == _selectedDay.month &&
                          dayDate.day == _selectedDay.day;
                      final isToday = dayDate.year == DateTime.now().year &&
                          dayDate.month == DateTime.now().month &&
                          dayDate.day == DateTime.now().day;

                      return InkWell(
                        onTap: () => setState(() => _selectedDay = dayDate),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isToday
                                    ? AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.15)
                                    : Colors.transparent),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isToday
                                      ? AppColors.primary.withValues(alpha: 0.5)
                                      : Colors.transparent),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : (isToday ? AppColors.primary : theme.colorScheme.onSurface),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (dayHasEntries)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: dayMoods.take(2).map((m) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 1),
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? Colors.white : m.color,
                                      ),
                                    );
                                  }).toList(),
                                )
                              else
                                const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(),

                  // En-tête de la journée sélectionnée
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          dayHeaderFormat[0].toUpperCase() + dayHeaderFormat.substring(1),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${dayEntries.length} ${locale == 'en' ? 'entry' : 'écrit(s)'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Liste des entrées de la journée
          if (dayEntries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        locale == 'en' ? 'No writing on this day' : 'Aucun écrit ce jour-là',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        locale == 'en'
                            ? 'Would you like to note a memory or a thought for this date?'
                            : 'Souhaitez-vous noter un souvenir ou une pensée pour cette date ?',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: Text(locale == 'en' ? 'Write for this day' : 'Écrire pour ce jour'),
                        onPressed: () => context.push(AppRoutes.journalNew),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = dayEntries[index];
                  final cat = categories.cast<JournalCategory?>().firstWhere(
                        (c) => c?.id == entry.categoryId,
                        orElse: () => null,
                      );
                  return JournalEntryCard(
                    entry: entry,
                    category: cat,
                    onTap: () => context.push('${AppRoutes.journal}/${entry.id}'),
                    onFavoriteToggle: () => ref
                        .read(journalEntriesProvider.notifier)
                        .toggleFavorite(entry.id),
                  );
                },
                childCount: dayEntries.length,
              ),
            ),
        ],
      ),
    );
  }
}

