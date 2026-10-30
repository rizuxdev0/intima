import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/security/lock_provider.dart';
import '../../../core/storage/storage_provider.dart';
import '../data/journal_repository.dart';
import '../domain/models/journal_attachment.dart';
import '../domain/models/journal_entry.dart';
import '../domain/models/journal_mood.dart';

/// Notifier d'état réactif pour la collection des entrées du journal.
class JournalEntriesNotifier extends AsyncNotifier<List<JournalEntry>> {
  late JournalRepository _repo;

  @override
  Future<List<JournalEntry>> build() async {
    final isDuress = ref.watch(isDuressModeProvider);
    if (isDuress) {
      final now = DateTime.now();
      return [
        JournalEntry(
          id: 'decoy_01',
          title: 'Idées cadeaux et lectures',
          content: 'Reprendre la lecture le soir. Noter les idées cadeaux pour les anniversaires à venir.',
          date: now,
          createdAt: now,
          updatedAt: now,
          mood: JournalMoodType.peaceful,
          categoryId: 'cat_personal',
          tags: const ['Lectures', 'Notes'],
        ),
        JournalEntry(
          id: 'decoy_02',
          title: 'Organisation et recettes de la semaine',
          content: 'Faire les courses le samedi matin : fruits frais, légumes de saison, café et pain complet.',
          date: now.subtract(const Duration(days: 3)),
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 3)),
          mood: JournalMoodType.motivated,
          categoryId: 'cat_personal',
          tags: const ['Organisation'],
        ),
      ];
    }

    final storage = await ref.watch(encryptedStorageProvider.future);
    _repo = JournalRepository(storage);
    return _repo.loadAll();
  }

  /// Ajoute une nouvelle entrée au journal.
  Future<JournalEntry> addEntry({
    String? title,
    required String content,
    required DateTime date,
    JournalMoodType mood = JournalMoodType.peaceful,
    int moodIntensity = 3,
    String categoryId = 'cat_personal',
    List<String> tags = const [],
    List<JournalAttachment> attachments = const [],
    bool isFavorite = false,
    bool isDraft = false,
    String? notes,
  }) async {
    const uuid = Uuid();
    final now = DateTime.now();
    final entry = JournalEntry(
      id: uuid.v4(),
      title: title?.trim().isNotEmpty == true ? title!.trim() : null,
      content: content,
      date: date,
      createdAt: now,
      updatedAt: now,
      mood: mood,
      moodIntensity: moodIntensity,
      categoryId: categoryId,
      tags: tags,
      attachments: attachments,
      isFavorite: isFavorite,
      isDraft: isDraft,
      notes: notes,
    );

    await _repo.save(entry);
    final all = [...?state.valueOrNull, entry]
      ..sort((a, b) => b.date.compareTo(a.date));
    state = AsyncData(all);
    return entry;
  }

  /// Met à jour une entrée existante.
  Future<void> updateEntry(JournalEntry entry) async {
    await _repo.save(entry);
    final all = state.valueOrNull?.map((e) => e.id == entry.id ? entry : e).toList() ?? [];
    all.sort((a, b) => b.date.compareTo(a.date));
    state = AsyncData(all);
  }

  /// Supprime définitivement une entrée.
  Future<void> deleteEntry(String entryId) async {
    await _repo.delete(entryId);
    final all = state.valueOrNull?.where((e) => e.id != entryId).toList() ?? [];
    state = AsyncData(all);
  }

  /// Bascule le statut favori / épinglé.
  Future<void> toggleFavorite(String entryId) async {
    await _repo.toggleFavorite(entryId);
    final all = state.valueOrNull?.map((e) {
      if (e.id == entryId) {
        return e.copyWith(isFavorite: !e.isFavorite);
      }
      return e;
    }).toList() ?? [];
    state = AsyncData(all);
  }

  /// Archive ou désarchive une entrée.
  Future<void> setArchived(String entryId, bool isArchived) async {
    await _repo.setArchived(entryId, isArchived);
    final all = state.valueOrNull?.map((e) {
      if (e.id == entryId) {
        return e.copyWith(isArchived: isArchived);
      }
      return e;
    }).toList() ?? [];
    state = AsyncData(all);
  }

  /// Duplique une entrée existante.
  Future<JournalEntry?> duplicateEntry(String entryId) async {
    final duplicated = await _repo.duplicate(entryId);
    if (duplicated != null) {
      final all = [duplicated, ...?state.valueOrNull]
        ..sort((a, b) => b.date.compareTo(a.date));
      state = AsyncData(all);
    }
    return duplicated;
  }
}

/// Provider principal du Journal.
final journalEntriesProvider =
    AsyncNotifierProvider<JournalEntriesNotifier, List<JournalEntry>>(
  JournalEntriesNotifier.new,
);

// ─── Providers de filtres et recherche ──────────────────────────────────────────

final journalSearchQueryProvider = StateProvider<String>((ref) => '');
final journalSelectedMoodFilterProvider = StateProvider<JournalMoodType?>((ref) => null);
final journalSelectedCategoryFilterProvider = StateProvider<String?>((ref) => null);
final journalSelectedTagFilterProvider = StateProvider<String?>((ref) => null);
final journalFavoriteOnlyFilterProvider = StateProvider<bool>((ref) => false);
final journalShowArchivedFilterProvider = StateProvider<bool>((ref) => false);

/// Entrées filtrées réactives selon tous les critères utilisateur actifs.
final journalFilteredEntriesProvider = Provider<List<JournalEntry>>((ref) {
  final entriesAsync = ref.watch(journalEntriesProvider);
  final entries = entriesAsync.valueOrNull ?? [];

  final query = ref.watch(journalSearchQueryProvider).trim().toLowerCase();
  final selectedMood = ref.watch(journalSelectedMoodFilterProvider);
  final selectedCategory = ref.watch(journalSelectedCategoryFilterProvider);
  final selectedTag = ref.watch(journalSelectedTagFilterProvider);
  final favoriteOnly = ref.watch(journalFavoriteOnlyFilterProvider);
  final showArchived = ref.watch(journalShowArchivedFilterProvider);

  return entries.where((e) {
    if (!showArchived && e.isArchived) return false;
    if (favoriteOnly && !e.isFavorite) return false;
    if (selectedMood != null && e.mood != selectedMood) return false;
    if (selectedCategory != null && e.categoryId != selectedCategory) return false;
    if (selectedTag != null && !e.tags.contains(selectedTag)) return false;

    if (query.isNotEmpty) {
      final inTitle = e.title?.toLowerCase().contains(query) ?? false;
      final inContent = e.content.toLowerCase().contains(query);
      final inTags = e.tags.any((t) => t.toLowerCase().contains(query));
      final inNotes = e.notes?.toLowerCase().contains(query) ?? false;
      if (!inTitle && !inContent && !inTags && !inNotes) return false;
    }

    return true;
  }).toList();
});

