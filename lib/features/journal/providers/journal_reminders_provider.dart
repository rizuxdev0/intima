import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_provider.dart';
import '../data/journal_reminders_repository.dart';
import '../domain/models/journal_reminder.dart';

class JournalRemindersNotifier extends AsyncNotifier<List<JournalReminder>> {
  late JournalRemindersRepository _repo;

  @override
  Future<List<JournalReminder>> build() async {
    final storage = await ref.watch(encryptedStorageProvider.future);
    _repo = JournalRemindersRepository(storage);
    return _repo.loadAll();
  }

  Future<void> saveReminder(JournalReminder reminder) async {
    await _repo.save(reminder);
    final all = await _repo.loadAll();
    state = AsyncData(all);
  }

  Future<void> deleteReminder(String id) async {
    await _repo.delete(id);
    final all = state.valueOrNull?.where((r) => r.id != id).toList() ?? [];
    state = AsyncData(all);
  }

  Future<void> toggleActive(String id) async {
    await _repo.toggleActive(id);
    final all = await _repo.loadAll();
    state = AsyncData(all);
  }
}

final journalRemindersProvider =
    AsyncNotifierProvider<JournalRemindersNotifier, List<JournalReminder>>(
  JournalRemindersNotifier.new,
);

