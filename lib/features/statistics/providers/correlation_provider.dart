import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../encounters/providers/encounters_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../../menstrual_cycle/providers/menstrual_cycle_provider.dart';
import '../domain/correlation_engine.dart';

/// Provider réactif fournissant le rapport de corrélations croisées
/// entre les cycles menstruels, les écrits du journal intime et les rencontres intimes.
final correlationReportProvider = Provider<CorrelationReport>((ref) {
  final cycles = ref.watch(menstrualCycleProvider).valueOrNull ?? [];
  final journalEntries = ref.watch(journalEntriesProvider).valueOrNull ?? [];
  final encounters = ref.watch(encountersProvider).valueOrNull ?? [];
  final prediction = ref.watch(cyclePredictionProvider);

  final avgCycle = prediction?.averageCycleDays ?? 28.0;
  final avgPeriod = prediction?.averagePeriodDays ?? 5.0;

  return CorrelationEngine.analyze(
    cycles: cycles,
    journalEntries: journalEntries,
    encounters: encounters,
    averageCycleDays: avgCycle,
    averagePeriodDays: avgPeriod,
  );
});

