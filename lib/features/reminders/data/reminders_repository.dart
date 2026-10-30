import '../../../core/constants/app_constants.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../../../shared/models/reminder.dart';

class RemindersRepository {
  const RemindersRepository(this._storage);
  final EncryptedStorage _storage;

  Future<List<Reminder>> loadAll() async {
    final list = await _storage.readJsonListFile(AppConstants.remindersFile);
    if (list == null) return [];
    return list
        .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Reminder> reminders) async {
    await _storage.writeJsonListFile(
      AppConstants.remindersFile,
      reminders.map((r) => r.toJson()).toList(),
    );
  }

  Future<void> save(Reminder reminder) async {
    final all = await loadAll();
    final idx = all.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) {
      all[idx] = reminder;
    } else {
      all.add(reminder);
    }
    await saveAll(all);
  }

  Future<void> delete(String reminderId) async {
    final all = await loadAll();
    all.removeWhere((r) => r.id == reminderId);
    await saveAll(all);
  }
}

