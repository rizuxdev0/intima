import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_provider.dart';
import '../data/journal_categories_repository.dart';
import '../domain/models/journal_category.dart';

class JournalCategoriesNotifier extends AsyncNotifier<List<JournalCategory>> {
  late JournalCategoriesRepository _repo;

  @override
  Future<List<JournalCategory>> build() async {
    final storage = await ref.watch(encryptedStorageProvider.future);
    _repo = JournalCategoriesRepository(storage);
    return _repo.loadAll();
  }

  Future<void> addCategory(JournalCategory category) async {
    await _repo.addCustomCategory(category);
    final all = [...?state.valueOrNull, category];
    state = AsyncData(all);
  }

  Future<void> deleteCategory(String id) async {
    await _repo.deleteCategory(id);
    final all = state.valueOrNull?.where((c) => c.id != id).toList() ?? [];
    state = AsyncData(all);
  }
}

final journalCategoriesProvider =
    AsyncNotifierProvider<JournalCategoriesNotifier, List<JournalCategory>>(
  JournalCategoriesNotifier.new,
);

