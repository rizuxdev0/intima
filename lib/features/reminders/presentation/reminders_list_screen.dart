import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/reminder.dart';
import '../providers/reminders_provider.dart';

class RemindersListScreen extends ConsumerWidget {
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.remindersTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.reminderNew),
        child: const Icon(Icons.add),
      ),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return EmptyStateView(
              icon: Icons.alarm_outlined,
              title: l10n.remindersEmpty,
              message: 'Planifiez vos rappels de pilule, dépistages ou rendez-vous intimes en toute discrétion.',
              actionLabel: l10n.remindersAdd,
              onAction: () => context.push(AppRoutes.reminderNew),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _ReminderTile(reminder: reminder);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.toastError)),
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return IntimaCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.alarm_rounded, color: AppColors.sage, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${du.DateUtils.formatDate(reminder.scheduledDate)} ${reminder.scheduledTime ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.isActive,
            onChanged: (_) {
              ref.read(remindersProvider.notifier).toggleActive(reminder.id);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'delete') {
                ref.read(remindersProvider.notifier).deleteReminder(reminder.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.toastDeleted)),
                );
              }
            },
            itemBuilder: (_) => [
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
    );
  }
}

