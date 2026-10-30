import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/intima_card.dart';
import '../domain/models/journal_reminder.dart';
import '../providers/journal_reminders_provider.dart';

/// Gestion des rappels programmés d'écriture pour le Journal Intime.
class JournalRemindersScreen extends ConsumerWidget {
  const JournalRemindersScreen({super.key});

  Future<void> _showReminderDialog(BuildContext context, WidgetRef ref, [JournalReminder? existing]) async {
    final locale = Localizations.localeOf(context).languageCode;
    TimeOfDay selectedTime = existing != null
        ? TimeOfDay(hour: existing.hour, minute: existing.minute)
        : const TimeOfDay(hour: 21, minute: 0);

    String message = existing?.message ??
        (locale == 'en'
            ? 'Take a few minutes to write down your thoughts.'
            : 'Prends quelques minutes pour noter tes pensées.');

    int discretionLevel = existing?.discretionLevel ?? 0;
    List<int> repeatDays = existing?.repeatDays.toList() ?? [1, 2, 3, 4, 5, 6, 7];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final theme = Theme.of(ctx);

          final dayLabels = locale == 'en'
              ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              : ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.alarm_rounded, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      existing != null
                          ? (locale == 'en' ? 'Edit Reminder' : 'Modifier le rappel')
                          : (locale == 'en' ? 'New Writing Reminder' : 'Nouveau rappel d\'écriture'),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Sélecteur d'heure
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_rounded, color: AppColors.accent),
                  title: Text(locale == 'en' ? 'Reminder Time' : 'Heure de notification'),
                  subtitle: Text(selectedTime.format(ctx)),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setDialogState(() => selectedTime = picked);
                      }
                    },
                    child: Text(locale == 'en' ? 'Change' : 'Modifier'),
                  ),
                ),

                const SizedBox(height: 12),

                // Jours de répétition
                Text(
                  locale == 'en' ? 'Repeat Days' : 'Jours de répétition',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final day = i + 1;
                    final isSelected = repeatDays.contains(day);
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          if (isSelected) {
                            if (repeatDays.length > 1) repeatDays.remove(day);
                          } else {
                            repeatDays.add(day);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 40,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            dayLabels[i],
                            style: TextStyle(
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Message suggéré ou personnalisé
                Text(
                  locale == 'en' ? 'Gentle Prompt Message' : 'Message d\'invitation',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: message,
                  isExpanded: true,
                  items: [
                    'Prends quelques minutes pour noter tes pensées.',
                    'Comment s\'est passée ta journée ?',
                    'Prends quelques minutes pour toi.',
                    'Un moment intime pour déposer tes souvenirs.',
                  ]
                      .map((msg) => DropdownMenuItem(
                            value: msg,
                            child: Text(msg, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => message = val);
                  },
                ),

                const SizedBox(height: 14),

                // Discrétion
                Row(
                  children: [
                    const Icon(Icons.visibility_off_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(locale == 'en' ? 'Discreet notification mode' : 'Notification discrète'),
                    const Spacer(),
                    Switch(
                      value: discretionLevel == 0,
                      onChanged: (val) {
                        setDialogState(() => discretionLevel = val ? 0 : 1);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Bouton d'enregistrement
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      const uuid = Uuid();
                      final hourStr = selectedTime.hour.toString().padLeft(2, '0');
                      final minStr = selectedTime.minute.toString().padLeft(2, '0');
                      final reminder = JournalReminder(
                        id: existing?.id ?? uuid.v4(),
                        time: '$hourStr:$minStr',
                        repeatDays: repeatDays,
                        message: message,
                        isActive: true,
                        discretionLevel: discretionLevel,
                        createdAt: existing?.createdAt ?? DateTime.now(),
                      );

                      await ref.read(journalRemindersProvider.notifier).saveReminder(reminder);
                      if (context.mounted) Navigator.of(ctx).pop();
                    },
                    child: Text(locale == 'en' ? 'Save Reminder' : 'Enregistrer le rappel'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final remindersAsync = ref.watch(journalRemindersProvider);
    final reminders = remindersAsync.valueOrNull ?? [];

    return Scaffold(
      body: reminders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_active_outlined, size: 52, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      locale == 'en' ? 'No writing reminders set' : 'Aucun rappel d\'écriture programmé',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      locale == 'en'
                          ? 'Set a daily or weekly gentle notification to take time for yourself.'
                          : 'Programmez une notification discrète quotidienne ou hebdomadaire pour vous réserver ce moment privilégié.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(locale == 'en' ? 'Add Reminder' : 'Programmer un rappel'),
                      onPressed: () => _showReminderDialog(context, ref),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: reminders.length,
              itemBuilder: (context, i) {
                final rem = reminders[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: IntimaCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: rem.isActive
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : theme.colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.access_time_filled_rounded,
                            color: rem.isActive ? AppColors.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rem.time,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: rem.isActive ? null : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rem.message,
                                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rem.repeatDays.length == 7
                                    ? (locale == 'en' ? 'Every day' : 'Tous les jours')
                                    : '${rem.repeatDays.length} ${locale == 'en' ? 'days / week' : 'jours / semaine'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: rem.isActive,
                          onChanged: (_) =>
                              ref.read(journalRemindersProvider.notifier).toggleActive(rem.id),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showReminderDialog(context, ref, rem);
                            } else if (val == 'delete') {
                              ref.read(journalRemindersProvider.notifier).deleteReminder(rem.id);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: locale == 'en' ? 'Add Reminder' : 'Ajouter un rappel',
        onPressed: () => _showReminderDialog(context, ref),
        child: const Icon(Icons.add_alarm_rounded),
      ),
    );
  }
}

