import '../../../core/constants/app_constants.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../domain/models/journal_category.dart';

/// Repository pour la gestion des catégories prédéfinies et personnalisées.
class JournalCategoriesRepository {
  const JournalCategoriesRepository(this._storage);

  final EncryptedStorage _storage;

  Future<List<JournalCategory>> loadAll() async {
    final list = await _storage.readJsonListFile(AppConstants.journalCategoriesFile);
    if (list == null || list.isEmpty) {
      // Si aucun fichier sauvegardé, initialiser avec les catégories par défaut
      final defaults = JournalCategory.defaultCategories;
      await saveAll(defaults);
      return defaults;
    }
    return list
        .map((e) => JournalCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<JournalCategory> categories) async {
    await _storage.writeJsonListFile(
      AppConstants.journalCategoriesFile,
      categories.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> addCustomCategory(JournalCategory category) async {
    final all = await loadAll();
    all.add(category);
    await saveAll(all);
  }

  Future<void> deleteCategory(String id) async {
    final all = await loadAll();
    all.removeWhere((c) => c.id == id && !c.isDefault);
    await saveAll(all);
  }
}

