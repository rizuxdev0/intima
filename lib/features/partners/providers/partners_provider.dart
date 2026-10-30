import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/security/lock_provider.dart';
import '../../../core/storage/storage_provider.dart';
import '../../../shared/models/partner.dart';
import '../data/partners_repository.dart';

class PartnersNotifier extends AsyncNotifier<List<Partner>> {
  late PartnersRepository _repo;

  @override
  Future<List<Partner>> build() async {
    final isDuress = ref.watch(isDuressModeProvider);
    if (isDuress) return const [];

    final storage = await ref.watch(encryptedStorageProvider.future);
    _repo = PartnersRepository(storage);
    return _repo.loadAll();
  }

  Future<Partner> addPartner({
    String? name,
    int color = 0xFF6D426D,
    String? emoji,
    DateTime? firstMetDate,
    String? notes,
    List<String> tags = const [],
  }) async {
    const uuid = Uuid();
    final partner = Partner(
      id: uuid.v4(),
      createdAt: DateTime.now(),
      name: name,
      color: color,
      emoji: emoji,
      firstMetDate: firstMetDate,
      notes: notes,
      tags: tags,
    );
    await _repo.save(partner);
    state = AsyncData([...?state.valueOrNull, partner]);
    return partner;
  }

  Future<void> updatePartner(Partner partner) async {
    await _repo.save(partner);
    final all = state.valueOrNull ?? [];
    final idx = all.indexWhere((p) => p.id == partner.id);
    if (idx >= 0) {
      final updated = [...all];
      updated[idx] = partner;
      state = AsyncData(updated);
    }
  }

  Future<void> archivePartner(String id) async {
    final partner = (state.valueOrNull ?? []).firstWhere((p) => p.id == id);
    await updatePartner(partner.copyWith(isArchived: true));
  }

  Future<void> restorePartner(String id) async {
    final partner = (state.valueOrNull ?? []).firstWhere((p) => p.id == id);
    await updatePartner(partner.copyWith(isArchived: false));
  }

  /// Suppression complète : fiche + rencontres associées.
  Future<void> deletePartner(String id) async {
    await _repo.delete(id);
    final all = state.valueOrNull ?? [];
    state = AsyncData(all.where((p) => p.id != id).toList());
  }

  List<Partner> get activePartners =>
      (state.valueOrNull ?? []).where((p) => !p.isArchived).toList();

  List<Partner> get archivedPartners =>
      (state.valueOrNull ?? []).where((p) => p.isArchived).toList();

  Partner? findById(String id) {
    try {
      return (state.valueOrNull ?? []).firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

final partnersProvider =
    AsyncNotifierProvider<PartnersNotifier, List<Partner>>(
  PartnersNotifier.new,
);

