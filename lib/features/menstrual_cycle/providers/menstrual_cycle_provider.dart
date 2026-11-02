import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/security/lock_provider.dart';
import '../../../core/storage/storage_provider.dart';
import '../../../shared/models/menstrual_cycle.dart';
import '../../settings/providers/preferences_provider.dart';
import '../data/menstrual_cycle_repository.dart';
import '../domain/cycle_calculation_engine.dart';

class MenstrualCycleNotifier extends AsyncNotifier<List<MenstrualCycle>> {
  late MenstrualCycleRepository _repo;

  @override
  Future<List<MenstrualCycle>> build() async {
    final isDuress = ref.watch(isDuressModeProvider);
    if (isDuress) return const [];

    final storage = await ref.watch(encryptedStorageProvider.future);
    _repo = MenstrualCycleRepository(storage);
    return _repo.loadAll();
  }

  Future<MenstrualCycle> startCycle({
    required DateTime startDate,
    String profileId = 'self',
    int? flowIntensity,
    String? observations,
    String? treatment,
  }) async {
    const uuid = Uuid();
    final cycle = MenstrualCycle(
      id: uuid.v4(),
      startDate: startDate,
      createdAt: DateTime.now(),
      profileId: profileId,
      flowIntensity: flowIntensity,
      observations: observations,
      treatment: treatment,
    );
    await _repo.save(cycle);
    final all = [...?state.valueOrNull, cycle]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    state = AsyncData(all);
    await _syncPeriodAlert();
    return cycle;
  }

  Future<void> updateCycle(MenstrualCycle cycle) async {
    await _repo.save(cycle);
    final all = state.valueOrNull ?? [];
    final idx = all.indexWhere((c) => c.id == cycle.id);
    if (idx >= 0) {
      final updated = [...all];
      updated[idx] = cycle;
      updated.sort((a, b) => b.startDate.compareTo(a.startDate));
      state = AsyncData(updated);
      await _syncPeriodAlert();
    }
  }

  Future<void> deleteCycle(String id) async {
    await _repo.delete(id);
    final all = state.valueOrNull ?? [];
    state = AsyncData(all.where((c) => c.id != id).toList());
    await _syncPeriodAlert();
  }

  Future<void> _syncPeriodAlert() async {
    try {
      final prefs = ref.read(preferencesProvider).valueOrNull;
      if (prefs == null || !prefs.notificationsEnabled || prefs.periodReminderDaysBefore <= 0) {
        return;
      }
      final pred = prediction;
      if (pred.estimatedNextPeriodStart != null) {
        await NotificationService.schedulePeriodReminder(
          estimatedStartDate: pred.estimatedNextPeriodStart!,
          daysBefore: prefs.periodReminderDaysBefore,
          discretionLevel: prefs.notificationDiscretion,
        );
      }
    } catch (_) {}
  }

  Future<void> addSymptom(String cycleId, CycleSymptom symptom) async {
    final cycle = (state.valueOrNull ?? []).firstWhere((c) => c.id == cycleId);
    final updated = cycle.copyWith(
      symptoms: [...cycle.symptoms, symptom],
    );
    await updateCycle(updated);
  }

  /// Retourne les cycles triés du plus ancien au plus récent (pour les calculs).
  List<MenstrualCycle> get sortedAscending =>
      [...(state.valueOrNull ?? [])]
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  /// Calcule les prédictions à partir de tous les cycles enregistrés.
  CyclePrediction get prediction =>
      CycleCalculationEngine.calculate(sortedAscending);

  /// Retourne le cycle en cours (dernier cycle dont la date de fin est inconnue).
  MenstrualCycle? get currentCycle {
    final all = state.valueOrNull ?? [];
    if (all.isEmpty) return null;
    return all.first.endDate == null ? all.first : null;
  }
}

final menstrualCycleProvider =
    AsyncNotifierProvider<MenstrualCycleNotifier, List<MenstrualCycle>>(
  MenstrualCycleNotifier.new,
);

/// Provider calculant les prédictions dérivées.
final cyclePredictionProvider = Provider<CyclePrediction?>((ref) {
  final cyclesAsync = ref.watch(menstrualCycleProvider);
  return cyclesAsync.whenOrNull(
    data: (cycles) {
      final sorted = [...cycles]..sort((a, b) => a.startDate.compareTo(b.startDate));
      return CycleCalculationEngine.calculate(sorted);
    },
  );
});

