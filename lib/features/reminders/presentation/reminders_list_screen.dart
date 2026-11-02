import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/illustrations/intima_illustrations.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/reminder.dart';
import '../providers/reminders_provider.dart';

/// Écran de gestion et de consultation des rappels confidentiels.
/// Dispose d'un panneau héroïque avec compte à rebours dynamique du prochain rappel,
/// d'un minuteur avec pulsation or rose pour les rappels imminents (< 5 min),
/// d'une barre de filtres rapides par catégorie et d'accordéons thématiques.
class RemindersListScreen extends ConsumerStatefulWidget {
  const RemindersListScreen({super.key});

  @override
  ConsumerState<RemindersListScreen> createState() => _RemindersListScreenState();

  /// Calcule l'occurrence prochaine d'un rappel selon sa fréquence et son heure.
  static DateTime getEffectiveDateTime(Reminder reminder) {
    var date = reminder.scheduledDate;
    if (reminder.scheduledTime != null && reminder.scheduledTime!.contains(':')) {
      final parts = reminder.scheduledTime!.split(':');
      final h = int.tryParse(parts[0]) ?? date.hour;
      final m = int.tryParse(parts[1]) ?? date.minute;
      date = DateTime(date.year, date.month, date.day, h, m);
    }
    final now = DateTime.now();
    if (reminder.frequency == ReminderFrequency.daily) {
      final todayTarget = DateTime(now.year, now.month, now.day, date.hour, date.minute);
      return todayTarget.isAfter(now) ? todayTarget : todayTarget.add(const Duration(days: 1));
    } else if (reminder.frequency == ReminderFrequency.weekly) {
      var nextWeekly = date;
      while (nextWeekly.isBefore(now)) {
        nextWeekly = nextWeekly.add(const Duration(days: 7));
      }
      return nextWeekly;
    } else if (reminder.frequency == ReminderFrequency.monthly) {
      var nextMonthly = date;
      while (nextMonthly.isBefore(now)) {
        nextMonthly = DateTime(
          nextMonthly.year,
          nextMonthly.month + 1,
          nextMonthly.day,
          nextMonthly.hour,
          nextMonthly.minute,
        );
      }
      return nextMonthly;
    }
    return date;
  }
}

class _RemindersListScreenState extends ConsumerState<RemindersListScreen> {
  ReminderCategory? _selectedCategory;
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    // Rafraîchir les compteurs et l'heure relative toutes les 30 secondes
    _tickerTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.remindersTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Centre de notifications',
            onPressed: () => context.push(AppRoutes.notifications),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.reminderNew),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Nouveau rappel'),
      ),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return EmptyStateView(
              icon: Icons.alarm_outlined,
              illustrationType: IntimaIllustrationType.shield,
              title: l10n.remindersEmpty,
              message:
                  'Planifiez vos prises de pilule, bilans de santé ou rendez-vous en toute discrétion et 100% hors ligne.',
              actionLabel: l10n.remindersAdd,
              onAction: () => context.push(AppRoutes.reminderNew),
            );
          }

          final now = DateTime.now();

          // Calcul des totaux par catégorie pour les badges des FilterChips
          final categoryCounts = <ReminderCategory, int>{};
          for (final r in reminders) {
            categoryCounts[r.category] = (categoryCounts[r.category] ?? 0) + 1;
          }

          // Filtrage selon la catégorie sélectionnée
          final filteredReminders = _selectedCategory == null
              ? reminders
              : reminders.where((r) => r.category == _selectedCategory).toList();

          final activeReminders = filteredReminders.where((r) => r.isActive).toList();
          final inactiveReminders = filteredReminders.where((r) => !r.isActive).toList();

          // Calcul du prochain rappel imminent actif
          Reminder? nextReminder;
          DateTime? nextReminderTarget;

          for (final r in activeReminders) {
            final target = RemindersListScreen.getEffectiveDateTime(r);
            if (target.isAfter(now)) {
              if (nextReminderTarget == null || target.isBefore(nextReminderTarget)) {
                nextReminderTarget = target;
                nextReminder = r;
              }
            }
          }

          // Classification en sous-groupes thématiques
          final sevenDaysLater = now.add(const Duration(days: 7));

          // 1. Rappels imminents (< 7 jours, non récurrents quotidiens)
          final imminentReminders = activeReminders.where((r) {
            if (r.frequency == ReminderFrequency.daily) return false;
            final target = RemindersListScreen.getEffectiveDateTime(r);
            return target.isAfter(now) && target.isBefore(sevenDaysLater);
          }).toList()
            ..sort((a, b) => RemindersListScreen.getEffectiveDateTime(a)
                .compareTo(RemindersListScreen.getEffectiveDateTime(b)));

          // 2. Rappels récurrents (quotidiens & hebdomadaires)
          final recurringReminders = activeReminders.where((r) {
            return r.frequency == ReminderFrequency.daily ||
                r.frequency == ReminderFrequency.weekly ||
                r.frequency == ReminderFrequency.monthly;
          }).toList()
            ..sort((a, b) => RemindersListScreen.getEffectiveDateTime(a)
                .compareTo(RemindersListScreen.getEffectiveDateTime(b)));

          // 3. Rappels lointains (> 7 jours)
          final distantReminders = activeReminders.where((r) {
            if (r.frequency != ReminderFrequency.once) return false;
            final target = RemindersListScreen.getEffectiveDateTime(r);
            return target.isAfter(sevenDaysLater);
          }).toList()
            ..sort((a, b) => RemindersListScreen.getEffectiveDateTime(a)
                .compareTo(RemindersListScreen.getEffectiveDateTime(b)));

          // 4. Rappels passés ou inactifs
          final pastReminders = [
            ...inactiveReminders,
            ...activeReminders.where((r) {
              if (r.frequency != ReminderFrequency.once) return false;
              final target = RemindersListScreen.getEffectiveDateTime(r);
              return target.isBefore(now);
            }),
          ];

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            children: [
              // ─── CARTE HÉROÏQUE DU PROCHAIN RAPPEL ──────────────────────────
              if (nextReminder != null && nextReminderTarget != null)
                _NextReminderHeroCard(
                  reminder: nextReminder,
                  targetDate: nextReminderTarget,
                )
              else
                _NoUpcomingHeroCard(onTapNew: () => context.push(AppRoutes.reminderNew)),

              const SizedBox(height: 16),

              // ─── BARRE DE FILTRES RAPIDES PAR CATÉGORIE ───────────────────
              _CategoryFilterChips(
                selectedCategory: _selectedCategory,
                categoryCounts: categoryCounts,
                totalCount: reminders.length,
                onSelect: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),

              const SizedBox(height: 16),

              // ─── ACCORDÉONS DE CLASSIFICATION ─────────────────────────────
              if (imminentReminders.isNotEmpty)
                _ReminderAccordion(
                  title: 'Cette semaine (Imminents)',
                  icon: Icons.flash_on_rounded,
                  iconColor: AppColors.accent,
                  count: imminentReminders.length,
                  initiallyExpanded: true,
                  reminders: imminentReminders,
                ),

              if (recurringReminders.isNotEmpty) ...[
                if (imminentReminders.isNotEmpty) const SizedBox(height: 12),
                _ReminderAccordion(
                  title: 'Rappels récurrents (Pilule & Rituels)',
                  icon: Icons.autorenew_rounded,
                  iconColor: AppColors.primary,
                  count: recurringReminders.length,
                  initiallyExpanded: true,
                  reminders: recurringReminders,
                ),
              ],

              if (distantReminders.isNotEmpty) ...[
                if (imminentReminders.isNotEmpty || recurringReminders.isNotEmpty)
                  const SizedBox(height: 12),
                _ReminderAccordion(
                  title: 'Échéances à venir',
                  icon: Icons.calendar_month_rounded,
                  iconColor: AppColors.sage,
                  count: distantReminders.length,
                  initiallyExpanded: false,
                  reminders: distantReminders,
                ),
              ],

              if (pastReminders.isNotEmpty) ...[
                if (imminentReminders.isNotEmpty ||
                    recurringReminders.isNotEmpty ||
                    distantReminders.isNotEmpty)
                  const SizedBox(height: 12),
                _ReminderAccordion(
                  title: 'Passés & Désactivés',
                  icon: Icons.history_rounded,
                  iconColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  count: pastReminders.length,
                  initiallyExpanded: false,
                  reminders: pastReminders,
                ),
              ],

              // Si le filtre ne renvoie aucun résultat
              if (filteredReminders.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.filter_list_off_rounded,
                          size: 40,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aucun rappel dans cette catégorie',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
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
}

// ─── BARRE DE FILTRES RAPIDES (FILTER CHIPS) ─────────────────────────────────

class _CategoryFilterChips extends StatelessWidget {
  const _CategoryFilterChips({
    required this.selectedCategory,
    required this.categoryCounts,
    required this.totalCount,
    required this.onSelect,
  });

  final ReminderCategory? selectedCategory;
  final Map<ReminderCategory, int> categoryCounts;
  final int totalCount;
  final ValueChanged<ReminderCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterChipItem(
            label: 'Tous',
            count: totalCount,
            icon: Icons.all_inclusive_rounded,
            isSelected: selectedCategory == null,
            color: AppColors.primary,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          _FilterChipItem(
            label: 'Contraception',
            count: categoryCounts[ReminderCategory.cycle] ?? 0,
            icon: Icons.water_drop_rounded,
            isSelected: selectedCategory == ReminderCategory.cycle,
            color: AppColors.calendarPeriod,
            onTap: () => onSelect(ReminderCategory.cycle),
          ),
          const SizedBox(width: 8),
          _FilterChipItem(
            label: 'Santé & Dépistage',
            count: categoryCounts[ReminderCategory.health] ?? 0,
            icon: Icons.shield_rounded,
            isSelected: selectedCategory == ReminderCategory.health,
            color: AppColors.accent,
            onTap: () => onSelect(ReminderCategory.health),
          ),
          const SizedBox(width: 8),
          _FilterChipItem(
            label: 'Médical',
            count: categoryCounts[ReminderCategory.medical] ?? 0,
            icon: Icons.medical_services_rounded,
            isSelected: selectedCategory == ReminderCategory.medical,
            color: Colors.blueAccent,
            onTap: () => onSelect(ReminderCategory.medical),
          ),
          const SizedBox(width: 8),
          _FilterChipItem(
            label: 'Personnel',
            count: categoryCounts[ReminderCategory.personal] ?? 0,
            icon: Icons.favorite_rounded,
            isSelected: selectedCategory == ReminderCategory.personal,
            color: AppColors.primary,
            onTap: () => onSelect(ReminderCategory.personal),
          ),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CARTE HÉROÏQUE DU PROCHAIN RAPPEL AVEC COMPTE À REBOURS ────────────────

class _NextReminderHeroCard extends ConsumerWidget {
  const _NextReminderHeroCard({
    required this.reminder,
    required this.targetDate,
  });

  final Reminder reminder;
  final DateTime targetDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remainingText = _formatRemainingTime(targetDate);
    final categoryInfo = _getCategoryDetails(reminder.category);
    final isImminentUnder5Min = _isUnder5Minutes(targetDate);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'PROCHAIN RAPPEL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Switch(
                value: reminder.isActive,
                activeColor: AppColors.accent,
                activeTrackColor: Colors.white24,
                inactiveThumbColor: Colors.white70,
                inactiveTrackColor: Colors.white12,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  ref.read(remindersProvider.notifier).toggleActive(reminder.id);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Compte à rebours dynamique avec pulsation si < 5 minutes
          Row(
            children: [
              Expanded(
                child: Text(
                  remainingText,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (isImminentUnder5Min)
                const _PulsingBeacon(
                  label: 'Bientôt',
                  color: AppColors.accent,
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Titre et détails
          Text(
            reminder.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          if (reminder.description != null && reminder.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              reminder.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Badges d'information
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _HeroBadge(
                icon: categoryInfo.icon,
                label: categoryInfo.label,
              ),
              _HeroBadge(
                icon: Icons.access_time_rounded,
                label: '${du.DateUtils.formatDate(targetDate)} à ${_formatTime(targetDate)}',
              ),
              if (reminder.frequency != ReminderFrequency.once)
                _HeroBadge(
                  icon: Icons.sync_rounded,
                  label: _getFrequencyLabel(reminder.frequency),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _NoUpcomingHeroCard extends StatelessWidget {
  const _NoUpcomingHeroCard({required this.onTapNew});

  final VoidCallback onTapNew;

  @override
  Widget build(BuildContext context) {
    return IntimaCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.sage, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aucun rappel en attente',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vos prochains rappels apparaîtront ici avec leur compte à rebours.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.add),
            onPressed: onTapNew,
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ACCORDÉON DÉROULANT PERSONNALISÉ ─────────────────────────────────────────

class _ReminderAccordion extends StatelessWidget {
  const _ReminderAccordion({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.initiallyExpanded,
    required this.reminders,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final int count;
  final bool initiallyExpanded;
  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          onExpansionChanged: (_) => HapticFeedback.selectionClick(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more_rounded),
            ],
          ),
          children: reminders.map((r) => _ReminderListTile(reminder: r)).toList(),
        ),
      ),
    );
  }
}

// ─── TUILE DE RAPPEL DANS L'ACCORDÉON ────────────────────────────────────────

class _ReminderListTile extends ConsumerWidget {
  const _ReminderListTile({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final targetDate = RemindersListScreen.getEffectiveDateTime(reminder);
    final remainingText = _formatRemainingTime(targetDate);
    final categoryDetails = _getCategoryDetails(reminder.category);
    final isPast = targetDate.isBefore(DateTime.now()) && reminder.frequency == ReminderFrequency.once;
    final isImminentUnder5Min = _isUnder5Minutes(targetDate);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icône de catégorie
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryDetails.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(categoryDetails.icon, color: categoryDetails.color, size: 20),
              ),
              const SizedBox(width: 12),

              // Titre et date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: (!reminder.isActive || isPast)
                            ? TextDecoration.lineThrough
                            : null,
                        color: (!reminder.isActive || isPast)
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${du.DateUtils.formatDate(targetDate)} • ${reminder.scheduledTime ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Interrupteur actif/inactif
              Switch(
                value: reminder.isActive,
                activeColor: AppColors.primary,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  ref.read(remindersProvider.notifier).toggleActive(reminder.id);
                },
              ),

              // Menu d'actions (Modifier / Supprimer)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (val) {
                  if (val == 'edit') {
                    context.push('/reminders/${reminder.id}/edit');
                  } else if (val == 'delete') {
                    ref.read(remindersProvider.notifier).deleteReminder(reminder.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.toastDeleted)),
                    );
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          l10n.commonDelete,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Description facultative
          if (reminder.description != null && reminder.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Text(
                reminder.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Ligne de tags : Compte à rebours pulsant + Fréquence + Discrétion
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                // Tag de temps restant (avec pulsation or rose si < 5 minutes)
                _PulsingTimeBadge(
                  label: remainingText,
                  isImminent: reminder.isActive && !isPast && isImminentUnder5Min,
                  color: (!reminder.isActive || isPast)
                      ? Colors.grey
                      : (remainingText.contains('min') || remainingText.contains('Imminent')
                          ? AppColors.accent
                          : AppColors.primary),
                ),

                // Tag de fréquence
                if (reminder.frequency != ReminderFrequency.once)
                  _TagChip(
                    label: _getFrequencyLabel(reminder.frequency),
                    color: AppColors.sage,
                  ),

                // Tag de discrétion
                _TagChip(
                  label: _getDiscretionLabel(reminder.discretionLevel),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MINUTEUR EN DIRECT AVEC PULSATION OR ROSE (< 5 MINUTES) ─────────────────

class _PulsingTimeBadge extends StatefulWidget {
  const _PulsingTimeBadge({
    required this.label,
    required this.isImminent,
    required this.color,
  });

  final String label;
  final bool isImminent;
  final Color color;

  @override
  State<_PulsingTimeBadge> createState() => _PulsingTimeBadgeState();
}

class _PulsingTimeBadgeState extends State<_PulsingTimeBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowAnimation = Tween<double>(begin: 0.25, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isImminent) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingTimeBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isImminent && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isImminent && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isImminent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 11,
            color: widget.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15 + 0.15 * _glowAnimation.value),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: _glowAnimation.value),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35 * _glowAnimation.value),
                blurRadius: 8 * _glowAnimation.value,
                spreadRadius: 1 * _glowAnimation.value,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: _glowAnimation.value),
                      blurRadius: 5,
                      spreadRadius: 1.5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PulsingBeacon extends StatefulWidget {
  const _PulsingBeacon({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  State<_PulsingBeacon> createState() => _PulsingBeaconState();
}

class _PulsingBeaconState extends State<_PulsingBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.25 * _pulse.value),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withValues(alpha: _pulse.value),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 * _pulse.value),
                blurRadius: 10 * _pulse.value,
                spreadRadius: 2 * _pulse.value,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: _pulse.value),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── FONCTIONS UTILITAIRES DE TEMPS RESTANT & LABELS ─────────────────────────

bool _isUnder5Minutes(DateTime target) {
  final now = DateTime.now();
  final diff = target.difference(now);
  return !diff.isNegative && diff <= const Duration(minutes: 5);
}

String _formatRemainingTime(DateTime target) {
  final now = DateTime.now();
  final diff = target.difference(now);

  if (diff.isNegative) {
    final past = now.difference(target);
    if (past.inMinutes < 60) {
      return 'Passé (il y a ${past.inMinutes} min)';
    } else if (past.inHours < 24) {
      return 'Passé (il y a ${past.inHours} h)';
    } else {
      return 'Passé (${past.inDays}j)';
    }
  }

  if (diff.inSeconds < 60) {
    return 'Imminent (< 1 min)';
  } else if (diff.inMinutes < 60) {
    return 'Dans ${diff.inMinutes} min';
  } else if (diff.inHours < 24) {
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    return mins > 0 ? 'Dans ${hours}h ${mins}min' : 'Dans ${hours}h';
  } else if (diff.inDays == 1) {
    final hours = diff.inHours % 24;
    return hours > 0 ? 'Demain (dans 1j ${hours}h)' : 'Demain';
  } else if (diff.inDays < 7) {
    return 'Dans ${diff.inDays} jours';
  } else if (diff.inDays < 30) {
    final weeks = (diff.inDays / 7).floor();
    final remDays = diff.inDays % 7;
    return remDays > 0 ? 'Dans ${weeks} sem. et ${remDays} j' : 'Dans ${weeks} semaine(s)';
  } else {
    final months = (diff.inDays / 30).floor();
    return 'Dans ${months} mois';
  }
}

String _getFrequencyLabel(ReminderFrequency freq) {
  switch (freq) {
    case ReminderFrequency.daily:
      return 'Chaque jour';
    case ReminderFrequency.weekly:
      return 'Chaque semaine';
    case ReminderFrequency.monthly:
      return 'Chaque mois';
    case ReminderFrequency.once:
      return 'Une fois';
  }
}

String _getDiscretionLabel(int level) {
  switch (level) {
    case 0:
      return 'Discret';
    case 1:
      return 'Neutre';
    case 2:
      return 'Détaillé';
    default:
      return 'Discret';
  }
}

class _CategoryDetails {
  const _CategoryDetails({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

_CategoryDetails _getCategoryDetails(ReminderCategory cat) {
  switch (cat) {
    case ReminderCategory.cycle:
      return const _CategoryDetails(
        label: 'Contraception / Cycle',
        icon: Icons.water_drop_rounded,
        color: AppColors.calendarPeriod,
      );
    case ReminderCategory.health:
      return const _CategoryDetails(
        label: 'Santé & Dépistage',
        icon: Icons.shield_rounded,
        color: AppColors.accent,
      );
    case ReminderCategory.medical:
      return const _CategoryDetails(
        label: 'Médical',
        icon: Icons.medical_services_rounded,
        color: Colors.blueAccent,
      );
    case ReminderCategory.personal:
      return const _CategoryDetails(
        label: 'Personnel',
        icon: Icons.favorite_rounded,
        color: AppColors.primary,
      );
  }
}
