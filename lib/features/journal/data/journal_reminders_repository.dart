import '../../../core/constants/app_constants.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../domain/models/journal_reminder.dart';

/// Repository pour la persistance et la planification des rappels d'écriture.
class JournalRemindersRepository {
  const JournalRemindersRepository(this._storage);

  final EncryptedStorage _storage;

  Future<List<JournalReminder>> loadAll() async {
    final list = await _storage.readJsonListFile(AppConstants.journalRemindersFile);
    if (list == null) return [];
    return list
        .map((e) => JournalReminder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<JournalReminder> reminders) async {
    await _storage.writeJsonListFile(
      AppConstants.journalRemindersFile,
      reminders.map((r) => r.toJson()).toList(),
    );
  }

  Future<void> save(JournalReminder reminder) async {
    final all = await loadAll();
    final idx = all.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) {
      all[idx] = reminder;
    } else {
      all.add(reminder);
    }
    await saveAll(all);
    await _scheduleReminderNotification(reminder);
  }

  Future<void> delete(String reminderId) async {
    final all = await loadAll();
    all.removeWhere((r) => r.id == reminderId);
    await saveAll(all);
    await NotificationService.cancelNotification(reminderId.hashCode);
  }

  Future<void> toggleActive(String reminderId) async {
    final all = await loadAll();
    final idx = all.indexWhere((r) => r.id == reminderId);
    if (idx >= 0) {
      final updated = all[idx].copyWith(isActive: !all[idx].isActive);
      all[idx] = updated;
      await saveAll(all);

      if (updated.isActive) {
        await _scheduleReminderNotification(updated);
      } else {
        await NotificationService.cancelNotification(updated.id.hashCode);
      }
    }
  }

  Future<void> _scheduleReminderNotification(JournalReminder reminder) async {
    if (!reminder.isActive) return;

    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await NotificationService.scheduleNotification(
        id: reminder.id.hashCode,
        title: 'Journal Intime',
        body: reminder.message,
        scheduledDate: scheduled,
        discretionLevel: reminder.discretionLevel,
      );
    } catch (_) {
      // Échec silencieux si permissions désactivées
    }
  }
}

