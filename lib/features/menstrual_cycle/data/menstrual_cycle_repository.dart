import '../../../core/constants/app_constants.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../../../shared/models/menstrual_cycle.dart';

class MenstrualCycleRepository {
  const MenstrualCycleRepository(this._storage);
  final EncryptedStorage _storage;

  Future<List<MenstrualCycle>> loadAll() async {
    final list =
        await _storage.readJsonListFile(AppConstants.menstrualCyclesFile);
    if (list == null) return [];
    return list
        .map((e) => MenstrualCycle.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<void> saveAll(List<MenstrualCycle> cycles) async {
    await _storage.writeJsonListFile(
      AppConstants.menstrualCyclesFile,
      cycles.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> save(MenstrualCycle cycle) async {
    final all = await loadAll();
    final idx = all.indexWhere((c) => c.id == cycle.id);
    if (idx >= 0) {
      all[idx] = cycle;
    } else {
      all.add(cycle);
    }
    await saveAll(all);
  }

  Future<void> delete(String cycleId) async {
    final all = await loadAll();
    all.removeWhere((c) => c.id == cycleId);
    await saveAll(all);
  }
}

