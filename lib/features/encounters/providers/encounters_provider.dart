import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/security/lock_provider.dart';
import '../../../core/storage/storage_provider.dart';
import '../../../shared/models/encounter.dart';
import '../data/encounters_repository.dart';

class EncountersNotifier extends AsyncNotifier<List<Encounter>> {
  late EncountersRepository _repo;

  @override
  Future<List<Encounter>> build() async {
    final isDuress = ref.watch(isDuressModeProvider);
    if (isDuress) return const [];

    final storage = await ref.watch(encryptedStorageProvider.future);
    _repo = EncountersRepository(storage);
    return _repo.loadAll();
  }

  Future<Encounter> addEncounter({
    required DateTime date,
    String? partnerId,
    String? time,
    int? durationMinutes,
    EncounterType type = EncounterType.intimate,
    String? customTypeName,
    String? notes,
    int? moodBefore,
    int? moodAfter,
    ProtectionType? protectionUsed,
    bool protectionIssue = false,
    String? contraception,
    List<String> symptoms = const [],
    List<String> tags = const [],
  }) async {
    const uuid = Uuid();
    final encounter = Encounter(
      id: uuid.v4(),
      date: date,
      createdAt: DateTime.now(),
      partnerId: partnerId,
      time: time,
      durationMinutes: durationMinutes,
      type: type,
      customTypeName: customTypeName,
      notes: notes,
      moodBefore: moodBefore,
      moodAfter: moodAfter,
      protectionUsed: protectionUsed,
      protectionIssue: protectionIssue,
      contraception: contraception,
      symptoms: symptoms,
      tags: tags,
    );
    await _repo.save(encounter);
    final all = [...?state.valueOrNull, encounter]
      ..sort((a, b) => b.date.compareTo(a.date));
    state = AsyncData(all);
    return encounter;
  }

  Future<void> updateEncounter(Encounter encounter) async {
    await _repo.save(encounter);
    final all = state.valueOrNull ?? [];
    final idx = all.indexWhere((e) => e.id == encounter.id);
    if (idx >= 0) {
      final updated = [...all];
      updated[idx] = encounter;
      updated.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncData(updated);
    }
  }

  Future<void> deleteEncounter(String id) async {
    await _repo.delete(id);
    final all = state.valueOrNull ?? [];
    state = AsyncData(all.where((e) => e.id != id).toList());
  }

  /// Retourne les rencontres filtrées par partenaire.
  List<Encounter> byPartner(String partnerId) =>
      (state.valueOrNull ?? [])
          .where((e) => e.partnerId == partnerId)
          .toList();

  /// Retourne les rencontres dans une période.
  List<Encounter> inPeriod(DateTime start, DateTime end) =>
      (state.valueOrNull ?? [])
          .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
          .toList();

  /// Compte les rencontres du mois courant.
  int get thisMonthCount {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return inPeriod(start, end).length;
  }
}

final encountersProvider =
    AsyncNotifierProvider<EncountersNotifier, List<Encounter>>(
  EncountersNotifier.new,
);

