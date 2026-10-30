import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/journal_stats.dart';
import 'journal_provider.dart';

/// Provider dérivé pour les statistiques globales du journal.
final journalStatsProvider = Provider<JournalStats>((ref) {
  final entriesAsync = ref.watch(journalEntriesProvider);
  final entries = entriesAsync.valueOrNull ?? [];
  return JournalStats.fromEntries(entries);
});

