import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/lock_provider.dart';
import '../../../core/storage/storage_provider.dart';
import '../data/sexual_health_repository.dart';
import '../domain/models/prep_record.dart';
import '../domain/models/sti_screening.dart';
import '../domain/models/vaccination_record.dart';

class SexualHealthNotifier extends AsyncNotifier<SexualHealthData> {
  late SexualHealthRepository _repo;

  @override
  Future<SexualHealthData> build() async {
    final isDuress = ref.watch(isDuressModeProvider);
    if (isDuress) return const SexualHealthData();

    final storage = await ref.watch(encryptedStorageProvider.future);
    _repo = SexualHealthRepository(storage);
    return _repo.load();
  }

  Future<void> saveScreening(StiScreening screening) async {
    await _repo.saveScreening(screening);
    final data = await _repo.load();
    state = AsyncData(data);
  }

  Future<void> deleteScreening(String id) async {
    await _repo.deleteScreening(id);
    final data = await _repo.load();
    state = AsyncData(data);
  }

  Future<void> saveVaccination(VaccinationRecord record) async {
    await _repo.saveVaccination(record);
    final data = await _repo.load();
    state = AsyncData(data);
  }

  Future<void> deleteVaccination(String id) async {
    await _repo.deleteVaccination(id);
    final data = await _repo.load();
    state = AsyncData(data);
  }

  Future<void> savePrep(PrepRecord prep) async {
    await _repo.savePrep(prep);
    final data = await _repo.load();
    state = AsyncData(data);
  }
}

final sexualHealthProvider =
    AsyncNotifierProvider<SexualHealthNotifier, SexualHealthData>(
  SexualHealthNotifier.new,
);

/// Nombre de jours écoulés depuis le dernier dépistage (null si jamais fait).
final daysSinceLastScreeningProvider = Provider<int?>((ref) {
  final dataAsync = ref.watch(sexualHealthProvider);
  final screenings = dataAsync.valueOrNull?.screenings ?? [];
  if (screenings.isEmpty) return null;
  final latest = screenings.first;
  return DateTime.now().difference(latest.date).inDays;
});

