import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/storage_provider.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../shared/models/reminder.dart';
import '../data/reminders_repository.dart';

class RemindersNotifier extends AsyncNotifier<List<Reminder>> {
  late RemindersRepository _repo;

  @override
  Future<List<Reminder>> build() async {
    final storage = await ref.watch(encryptedStorageProvider.future);
    _repo = RemindersRepository(storage);
    return _repo.loadAll();
  }

  Future<Reminder> addReminder({
    required String title,
    required DateTime scheduledDate,
    String? description,
    String? scheduledTime,
    ReminderFrequency frequency = ReminderFrequency.once,
    DateTime? endDate,
    ReminderCategory category = ReminderCategory.personal,
    int discretionLevel = 0,
    String? linkedEncounterId,
    String? linkedPartnerId,
  }) async {
    const uuid = Uuid();
    final notifId = DateTime.now().millisecondsSinceEpoch % 100000;

    final reminder = Reminder(
      id: uuid.v4(),
      title: title,
      description: description,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      frequency: frequency,
      endDate: endDate,
      category: category,
      discretionLevel: discretionLevel,
      isActive: true,
      notificationId: notifId,
      linkedEncounterId: linkedEncounterId,
      linkedPartnerId: linkedPartnerId,
      createdAt: DateTime.now(),
    );

    await _repo.save(reminder);
    await _scheduleNotification(reminder);

    final all = [...?state.valueOrNull, reminder];
    state = AsyncData(all);
    return reminder;
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _repo.save(reminder);

    // Reprogrammer la notification si actif
    if (reminder.notificationId != null) {
      await NotificationService.cancelNotification(reminder.notificationId!);
    }
    if (reminder.isActive) {
      await _scheduleNotification(reminder);
    }

    final all = state.valueOrNull ?? [];
    final idx = all.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) {
      final updated = [...all];
      updated[idx] = reminder;
      state = AsyncData(updated);
    }
  }

  Future<void> deleteReminder(String id) async {
    final reminder = (state.valueOrNull ?? []).firstWhere((r) => r.id == id);
    if (reminder.notificationId != null) {
      await NotificationService.cancelNotification(reminder.notificationId!);
    }
    await _repo.delete(id);
    final all = state.valueOrNull ?? [];
    state = AsyncData(all.where((r) => r.id != id).toList());
  }

  Future<void> toggleActive(String id) async {
    final reminder = (state.valueOrNull ?? []).firstWhere((r) => r.id == id);
    await updateReminder(reminder.copyWith(isActive: !reminder.isActive));
  }

  List<Reminder> get upcoming {
    final now = DateTime.now();
    return (state.valueOrNull ?? [])
        .where((r) => r.isActive && r.scheduledDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    try {
      var date = reminder.scheduledDate;
      if (reminder.scheduledTime != null && reminder.scheduledTime!.contains(':')) {
        final parts = reminder.scheduledTime!.split(':');
        final h = int.tryParse(parts[0]) ?? 9;
        final m = int.tryParse(parts[1]) ?? 0;
        date = DateTime(date.year, date.month, date.day, h, m);
      }
      await NotificationService.scheduleNotification(
        id: reminder.notificationId ?? 0,
        title: reminder.title,
        body: reminder.description ?? '',
        scheduledDate: date,
        discretionLevel: reminder.discretionLevel,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[RemindersNotifier] Erreur de planification de notification: $e');
    }
  }
}

final remindersProvider =
    AsyncNotifierProvider<RemindersNotifier, List<Reminder>>(
  RemindersNotifier.new,
);

