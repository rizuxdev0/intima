import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../shared/models/reminder.dart';
import '../providers/reminders_provider.dart';

class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({super.key, this.reminderId});

  final String? reminderId;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 9, minute: 0);
  ReminderFrequency _frequency = ReminderFrequency.once;
  ReminderCategory _category = ReminderCategory.personal;
  int _discretionLevel = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.reminderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final reminders = ref.read(remindersProvider).valueOrNull ?? [];
        final existing = reminders.where((r) => r.id == widget.reminderId).firstOrNull;
        if (existing != null && mounted) {
          setState(() {
            _titleController.text = existing.title;
            _descController.text = existing.description ?? '';
            _scheduledDate = existing.scheduledDate;
            if (existing.scheduledTime != null && existing.scheduledTime!.contains(':')) {
              final parts = existing.scheduledTime!.split(':');
              _scheduledTime = TimeOfDay(
                hour: int.tryParse(parts[0]) ?? 9,
                minute: int.tryParse(parts[1]) ?? 0,
              );
            }
            _frequency = existing.frequency;
            _category = existing.category;
            _discretionLevel = existing.discretionLevel;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context);

    try {
      // Demander proactivement les permissions de notification sur Android 13+ / iOS
      await NotificationService.requestPermissions();

      final timeStr =
          '${_scheduledTime.hour.toString().padLeft(2, '0')}:${_scheduledTime.minute.toString().padLeft(2, '0')}';

      // Fusionner la date sélectionnée et l'heure exacte choisie
      final fullScheduledDate = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );

      if (widget.reminderId != null) {
        final reminders = ref.read(remindersProvider).valueOrNull ?? [];
        final existing = reminders.where((r) => r.id == widget.reminderId).firstOrNull;
        if (existing != null) {
          final updated = existing.copyWith(
            title: _titleController.text.trim(),
            description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
            scheduledDate: fullScheduledDate,
            scheduledTime: timeStr,
            frequency: _frequency,
            category: _category,
            discretionLevel: _discretionLevel,
          );
          await ref.read(remindersProvider.notifier).updateReminder(updated);
        }
      } else {
        await ref.read(remindersProvider.notifier).addReminder(
              title: _titleController.text.trim(),
              description: _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
              scheduledDate: fullScheduledDate,
              scheduledTime: timeStr,
              frequency: _frequency,
              category: _category,
              discretionLevel: _discretionLevel,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.toastReminderScheduled)),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.toastError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEdit = widget.reminderId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier le rappel' : l10n.remindersAdd),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.commonSave),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Titre
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.reminderTitle,
                prefixIcon: const Icon(Icons.alarm_outlined),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10n.commonRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Catégorie
            const Text(
              'Catégorie du rappel',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Personnel'),
                  selected: _category == ReminderCategory.personal,
                  onSelected: (val) {
                    if (val) setState(() => _category = ReminderCategory.personal);
                  },
                ),
                ChoiceChip(
                  label: const Text('Contraception / Pilule'),
                  selected: _category == ReminderCategory.cycle,
                  onSelected: (val) {
                    if (val) setState(() => _category = ReminderCategory.cycle);
                  },
                ),
                ChoiceChip(
                  label: const Text('Santé & Dépistage'),
                  selected: _category == ReminderCategory.health,
                  onSelected: (val) {
                    if (val) setState(() => _category = ReminderCategory.health);
                  },
                ),
                ChoiceChip(
                  label: const Text('Médical'),
                  selected: _category == ReminderCategory.medical,
                  onSelected: (val) {
                    if (val) setState(() => _category = ReminderCategory.medical);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: '${l10n.reminderDescription} (${l10n.commonOptional})',
                prefixIcon: const Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // Date & Heure
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(l10n.reminderDate),
              subtitle: Text(du.DateUtils.formatDate(_scheduledDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _scheduledDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _scheduledDate = picked);
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time_outlined),
              title: Text(l10n.reminderTime),
              subtitle: Text(du.DateUtils.formatTime(_scheduledTime)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _scheduledTime,
                );
                if (picked != null) {
                  setState(() => _scheduledTime = picked);
                }
              },
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Fréquence
            Text(
              l10n.reminderFrequency,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.reminderFrequencyOnce),
                  selected: _frequency == ReminderFrequency.once,
                  onSelected: (val) {
                    if (val) setState(() => _frequency = ReminderFrequency.once);
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.reminderFrequencyDaily),
                  selected: _frequency == ReminderFrequency.daily,
                  onSelected: (val) {
                    if (val) setState(() => _frequency = ReminderFrequency.daily);
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.reminderFrequencyWeekly),
                  selected: _frequency == ReminderFrequency.weekly,
                  onSelected: (val) {
                    if (val) setState(() => _frequency = ReminderFrequency.weekly);
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.reminderFrequencyMonthly),
                  selected: _frequency == ReminderFrequency.monthly,
                  onSelected: (val) {
                    if (val) setState(() => _frequency = ReminderFrequency.monthly);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Discrétion de la notification
            Text(
              l10n.reminderDiscretion,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            RadioGroup<int>(
              groupValue: _discretionLevel,
              onChanged: (val) {
                if (val != null) setState(() => _discretionLevel = val);
              },
              child: Column(
                children: [
                  RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.reminderDiscretionDiscreet),
                    subtitle: const Text('« Tu as un rappel personnel. »'),
                    value: 0,
                  ),
                  RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.reminderDiscretionCustom),
                    subtitle: const Text('Titre seul, sans détails sensibles'),
                    value: 1,
                  ),
                  RadioListTile<int>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.reminderDiscretionDetailed),
                    subtitle: const Text('Titre et description visibles'),
                    value: 2,
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
