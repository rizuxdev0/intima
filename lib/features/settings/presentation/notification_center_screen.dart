import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/app_preferences.dart';
import '../providers/preferences_provider.dart';

/// Centre de notifications et de rappels discrets (accessible depuis les Paramètres).
class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  Future<void> _selectTime(
    BuildContext context,
    String currentTime,
    ValueChanged<String> onSelected,
  ) async {
    final parts = currentTime.split(':');
    final initialHour = int.tryParse(parts.first) ?? 8;
    final initialMinute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      onSelected('$hourStr:$minuteStr');
    }
  }

  Future<void> _sendTestNotification(
    BuildContext context,
    AppLocalizations l10n,
    AppPreferences prefs,
  ) async {
    try {
      final granted = await NotificationService.requestPermissions();
      if (!granted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationPermissionWarning),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      await NotificationService.showImmediateNotification(
        id: 9999,
        title: 'Rappel de santé intime',
        body: 'Prenez soin de vous : vérifiez vos notes et rappels du jour.',
        discretionLevel: prefs.notificationDiscretion,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationTestSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider).valueOrNull ?? const AppPreferences();
    final notifier = ref.read(preferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationCenterTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Interrupteur général
          IntimaCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
              ),
              title: Text(
                l10n.notificationMasterToggle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(l10n.notificationMasterDesc),
              value: prefs.notificationsEnabled,
              onChanged: (val) async {
                if (val) {
                  await NotificationService.requestPermissions();
                }
                await notifier.setNotificationsEnabled(val);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Niveau de discrétion
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.notificationDiscretionTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.notificationDiscretionDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                _DiscretionOption(
                  level: 0,
                  title: l10n.notificationDiscretion0,
                  subtitle: 'Texte d\'alerte 100% anonyme sur écran verrouillé',
                  isSelected: prefs.notificationDiscretion == 0,
                  onSelect: () => notifier.setNotificationDiscretion(0),
                ),
                const SizedBox(height: 8),
                _DiscretionOption(
                  level: 1,
                  title: l10n.notificationDiscretion1,
                  subtitle: 'Mentionne Intima sans révéler le contenu intime',
                  isSelected: prefs.notificationDiscretion == 1,
                  onSelect: () => notifier.setNotificationDiscretion(1),
                ),
                const SizedBox(height: 8),
                _DiscretionOption(
                  level: 2,
                  title: l10n.notificationDiscretion2,
                  subtitle: 'Affiche le titre complet de votre rappel',
                  isSelected: prefs.notificationDiscretion == 2,
                  onSelect: () => notifier.setNotificationDiscretion(2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Types de rappels programmés
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rappels automatiques hors ligne',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),

                // Alerte règles à venir
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.water_drop_rounded, color: AppColors.calendarPeriod),
                  title: Text(l10n.notificationPeriodTitle),
                  subtitle: Text(l10n.notificationPeriodDesc),
                  trailing: DropdownButton<int>(
                    value: prefs.periodReminderDaysBefore,
                    underline: const SizedBox.shrink(),
                    items: [1, 2, 3, 5, 7].map((days) {
                      return DropdownMenuItem<int>(
                        value: days,
                        child: Text(l10n.notificationPeriodDays(days)),
                      );
                    }).toList(),
                    onChanged: (days) {
                      if (days != null) {
                        notifier.setPeriodReminderDaysBefore(days);
                      }
                    },
                  ),
                ),
                const Divider(),

                // Rappel pilule / contraception
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.medication_rounded, color: AppColors.accent),
                  title: Text(l10n.notificationPillTitle),
                  subtitle: Text(l10n.notificationPillDesc),
                  value: prefs.pillReminderEnabled,
                  onChanged: (val) => notifier.setPillReminder(enabled: val),
                ),
                if (prefs.pillReminderEnabled)
                  Padding(
                    padding: const EdgeInsets.only(left: 48, bottom: 8),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time_rounded, size: 18),
                      label: Text('Heure du rappel : ${prefs.pillReminderTime}'),
                      onPressed: () => _selectTime(
                        context,
                        prefs.pillReminderTime,
                        (time) => notifier.setPillReminder(time: time),
                      ),
                    ),
                  ),
                const Divider(),

                // Check-in intime du soir
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.nightlight_round, color: AppColors.primary),
                  title: Text(l10n.notificationCheckinTitle),
                  subtitle: Text(l10n.notificationCheckinDesc),
                  value: prefs.dailyCheckinReminderEnabled,
                  onChanged: (val) => notifier.setDailyCheckinReminder(enabled: val),
                ),
                if (prefs.dailyCheckinReminderEnabled)
                  Padding(
                    padding: const EdgeInsets.only(left: 48, bottom: 8),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time_rounded, size: 18),
                      label: Text('Heure du journal : ${prefs.dailyCheckinReminderTime}'),
                      onPressed: () => _selectTime(
                        context,
                        prefs.dailyCheckinReminderTime,
                        (time) => notifier.setDailyCheckinReminder(time: time),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bouton test
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send_rounded),
            label: Text(l10n.notificationTestButton),
            onPressed: () => _sendTestNotification(context, l10n, prefs),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DiscretionOption extends StatelessWidget {
  const _DiscretionOption({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onSelect,
  });

  final int level;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
      ),
    );
  }
}

