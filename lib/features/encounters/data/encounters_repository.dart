import '../../../core/constants/app_constants.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../../../shared/models/encounter.dart';

class EncountersRepository {
  const EncountersRepository(this._storage);
  final EncryptedStorage _storage;

  Future<List<Encounter>> loadAll() async {
    final list = await _storage.readJsonListFile(AppConstants.encountersFile);
    if (list == null) return [];
    return list
        .map((e) => Encounter.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveAll(List<Encounter> encounters) async {
    await _storage.writeJsonListFile(
      AppConstants.encountersFile,
      encounters.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> save(Encounter encounter) async {
    final all = await loadAll();
    final idx = all.indexWhere((e) => e.id == encounter.id);
    if (idx >= 0) {
      all[idx] = encounter;
    } else {
      all.add(encounter);
    }
    await saveAll(all);
  }

  Future<void> delete(String encounterId) async {
    final all = await loadAll();
    all.removeWhere((e) => e.id == encounterId);
    await saveAll(all);
  }

  Future<void> deleteByPartnerId(String partnerId) async {
    final all = await loadAll();
    all.removeWhere((e) => e.partnerId == partnerId);
    await saveAll(all);
  }

  Future<void> anonymizeByPartnerId(String partnerId) async {
    final all = await loadAll();
    final updated = all.map((e) {
      if (e.partnerId == partnerId) {
        return e.copyWith(partnerId: null);
      }
      return e;
    }).toList();
    await saveAll(updated);
  }
}

