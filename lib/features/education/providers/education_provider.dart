import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_provider.dart';
import '../data/education_repository.dart';
import '../domain/models/educational_guide.dart';

/// Provider du repository des fiches éducatives.
final educationRepositoryProvider = FutureProvider<EducationRepository>((ref) async {
  final storage = await ref.watch(encryptedStorageProvider.future);
  return EducationRepository(storage);
});

/// Provider de l'ensemble du catalogue de fiches pédagogiques.
final allGuidesProvider = Provider<List<EducationalGuide>>((ref) {
  return EducationRepository.defaultCatalog;
});

/// État de la recherche textuelle dans le guide.
final guidesSearchQueryProvider = StateProvider<String>((ref) => '');

/// État du filtre de catégorie sélectionné (null = toutes).
final selectedGuideCategoryProvider = StateProvider<GuideCategory?>((ref) => null);

/// Notifier gérant la liste des identifiants des fiches mises en favoris.
class GuideFavoritesNotifier extends AsyncNotifier<Set<String>> {
  late EducationRepository _repo;

  @override
  Future<Set<String>> build() async {
    _repo = await ref.watch(educationRepositoryProvider.future);
    return _repo.getFavoriteIds();
  }

  Future<void> toggleFavorite(String guideId) async {
    final current = state.valueOrNull ?? <String>{};
    final updated = Set<String>.from(current);
    if (updated.contains(guideId)) {
      updated.remove(guideId);
    } else {
      updated.add(guideId);
    }
    state = AsyncData(updated);
    await _repo.saveFavoriteIds(updated);
  }
}

final guideFavoritesProvider =
    AsyncNotifierProvider<GuideFavoritesNotifier, Set<String>>(
  GuideFavoritesNotifier.new,
);

/// Provider filtré selon la requête textuelle et la catégorie.
final filteredGuidesProvider = Provider<List<EducationalGuide>>((ref) {
  final allGuides = ref.watch(allGuidesProvider);
  final query = ref.watch(guidesSearchQueryProvider).trim().toLowerCase();
  final selectedCategory = ref.watch(selectedGuideCategoryProvider);

  return allGuides.where((guide) {
    if (selectedCategory != null && guide.category != selectedCategory) {
      return false;
    }
    if (query.isEmpty) return true;

    final inTitle = guide.title.toLowerCase().contains(query);
    final inSubtitle = guide.subtitle.toLowerCase().contains(query);
    final inTags = guide.tags.any((t) => t.toLowerCase().contains(query));
    final inTakeaways = guide.keyTakeaways.any((k) => k.toLowerCase().contains(query));

    return inTitle || inSubtitle || inTags || inTakeaways;
  }).toList();
});

/// Provider d'une fiche spécifique par son ID.
final guideByIdProvider = Provider.family<EducationalGuide?, String>((ref, id) {
  final allGuides = ref.watch(allGuidesProvider);
  try {
    return allGuides.firstWhere((g) => g.id == id);
  } catch (_) {
    return null;
  }
});

