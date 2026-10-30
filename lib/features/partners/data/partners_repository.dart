import '../../../core/constants/app_constants.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../../../shared/models/partner.dart';

/// Repository de persistance des partenaires.
class PartnersRepository {
  const PartnersRepository(this._storage);
  final EncryptedStorage _storage;

  Future<List<Partner>> loadAll() async {
    final list = await _storage.readJsonListFile(AppConstants.partnersFile);
    if (list == null) return [];
    return list
        .map((e) => Partner.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Partner> partners) async {
    await _storage.writeJsonListFile(
      AppConstants.partnersFile,
      partners.map((p) => p.toJson()).toList(),
    );
  }

  Future<void> save(Partner partner) async {
    final all = await loadAll();
    final idx = all.indexWhere((p) => p.id == partner.id);
    if (idx >= 0) {
      all[idx] = partner;
    } else {
      all.add(partner);
    }
    await saveAll(all);
  }

  Future<void> delete(String partnerId) async {
    final all = await loadAll();
    all.removeWhere((p) => p.id == partnerId);
    await saveAll(all);
  }
}

