import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../domain/models/journal_entry.dart';
import '../domain/models/journal_mood.dart';

/// Repository pour la persistance 100% locale et chiffrée AES-256-GCM
/// des écrits du Journal Intime.
class JournalRepository {
  const JournalRepository(this._storage);

  final EncryptedStorage _storage;

  /// Charge toutes les entrées déchiffrées depuis le disque.
  Future<List<JournalEntry>> loadAll() async {
    final list = await _storage.readJsonListFile(AppConstants.journalEntriesFile);
    if (list == null) return [];
    return list
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Sauvegarde la totalité de la liste d'entrées.
  Future<void> saveAll(List<JournalEntry> entries) async {
    await _storage.writeJsonListFile(
      AppConstants.journalEntriesFile,
      entries.map((e) => e.toJson()).toList(),
    );
  }

  /// Crée ou met à jour une entrée.
  Future<void> save(JournalEntry entry) async {
    final all = await loadAll();
    final idx = all.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      all[idx] = entry.copyWith(updatedAt: DateTime.now());
    } else {
      all.add(entry);
    }
    await saveAll(all);
  }

  /// Supprime définitivement une entrée du journal.
  Future<void> delete(String entryId) async {
    final all = await loadAll();
    all.removeWhere((e) => e.id == entryId);
    await saveAll(all);
  }

  /// Archive ou désarchive une entrée.
  Future<void> setArchived(String entryId, bool isArchived) async {
    final all = await loadAll();
    final idx = all.indexWhere((e) => e.id == entryId);
    if (idx >= 0) {
      all[idx] = all[idx].copyWith(isArchived: isArchived, updatedAt: DateTime.now());
      await saveAll(all);
    }
  }

  /// Bascule le statut favori / épinglé.
  Future<void> toggleFavorite(String entryId) async {
    final all = await loadAll();
    final idx = all.indexWhere((e) => e.id == entryId);
    if (idx >= 0) {
      all[idx] = all[idx].copyWith(
        isFavorite: !all[idx].isFavorite,
        updatedAt: DateTime.now(),
      );
      await saveAll(all);
    }
  }

  /// Duplique une entrée existante pour la réutiliser ou la décliner.
  Future<JournalEntry?> duplicate(String entryId) async {
    final all = await loadAll();
    final idx = all.indexWhere((e) => e.id == entryId);
    if (idx < 0) return null;

    final orig = all[idx];
    const uuid = Uuid();
    final now = DateTime.now();

    final duplicated = orig.copyWith(
      id: uuid.v4(),
      title: orig.title != null ? '${orig.title} (Copie)' : 'Copie de note',
      date: now,
      createdAt: now,
      updatedAt: now,
      isDraft: false,
    );

    all.insert(0, duplicated);
    await saveAll(all);
    return duplicated;
  }

  /// Recherche avancée et filtrage multicritères.
  Future<List<JournalEntry>> search({
    String? query,
    JournalMoodType? mood,
    String? categoryId,
    String? tag,
    bool? favoriteOnly,
    bool includeArchived = false,
  }) async {
    final all = await loadAll();
    return all.where((e) {
      if (!includeArchived && e.isArchived) return false;
      if (favoriteOnly == true && !e.isFavorite) return false;
      if (mood != null && e.mood != mood) return false;
      if (categoryId != null && e.categoryId != categoryId) return false;
      if (tag != null && !e.tags.contains(tag)) return false;

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final inTitle = e.title?.toLowerCase().contains(q) ?? false;
        final inContent = e.content.toLowerCase().contains(q);
        final inTags = e.tags.any((t) => t.toLowerCase().contains(q));
        final inNotes = e.notes?.toLowerCase().contains(q) ?? false;
        if (!inTitle && !inContent && !inTags && !inNotes) return false;
      }

      return true;
    }).toList();
  }

  /// Efface toutes les entrées (purge de données demandée par l'utilisateur).
  Future<void> deleteAll() async {
    await saveAll([]);
  }
}

