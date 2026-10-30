import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/features/education/data/education_repository.dart';
import 'package:intima/features/search/domain/models/search_result_item.dart';
import 'package:intima/features/search/providers/search_provider.dart';

void main() {
  group('Global Search Tests (Spotlight Local)', () {
    test('La recherche dans les guides retourne les fiches contenant le mot-clé', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Simuler une recherche sur "HPV"
      container.read(searchQueryProvider.notifier).state = 'HPV';
      final results = container.read(globalSearchResultsProvider);

      expect(results, isNotEmpty);
      final hpvGuide = results.firstWhere((r) => r.category == SearchCategory.guide);
      expect(hpvGuide.title.contains('HPV') || hpvGuide.subtitle.contains('HPV'), isTrue);
    });

    test('Le filtrage par catégorie isole uniquement la catégorie sélectionnée', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).state = 'cycle';
      container.read(searchCategoryFilterProvider.notifier).state = SearchCategory.guide;

      final results = container.read(globalSearchResultsProvider);
      expect(results.every((r) => r.category == SearchCategory.guide), isTrue);
    });

    test('Une recherche vide avec le catalogue de base retourne les guides', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).state = '';
      container.read(searchCategoryFilterProvider.notifier).state = SearchCategory.guide;

      final results = container.read(globalSearchResultsProvider);
      expect(results.length, equals(EducationRepository.defaultCatalog.length));
    });
  });
}

