import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/storage/encrypted_storage.dart';
import 'package:intima/features/education/data/education_repository.dart';
import 'package:intima/features/education/domain/models/educational_guide.dart';

// Fake in-memory encrypted storage for testing
class InMemoryEncryptedStorage implements EncryptedStorage {
  final Map<String, List<dynamic>> _data = {};

  @override
  Future<List<dynamic>?> readJsonListFile(String filename) async => _data[filename];

  @override
  Future<void> writeJsonListFile(String filename, List<dynamic> data) async {
    _data[filename] = data;
  }

  @override
  Future<bool> deleteFile(String filename) async {
    return _data.remove(filename) != null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Education Module Tests', () {
    late EducationRepository repository;
    late InMemoryEncryptedStorage storage;

    setUp(() {
      storage = InMemoryEncryptedStorage();
      repository = EducationRepository(storage);
    });

    test('Le catalogue contient au moins 8 fiches complètes', () {
      final guides = repository.getAllGuides();
      expect(guides.length, greaterThanOrEqualTo(8));

      for (final g in guides) {
        expect(g.title.isNotEmpty, isTrue);
        expect(g.subtitle.isNotEmpty, isTrue);
        expect(g.keyTakeaways.isNotEmpty, isTrue);
        expect(g.sections.isNotEmpty, isTrue);
        expect(g.readingTimeMinutes, greaterThan(0));
      }
    });

    test('Recherche d\'un guide par ID existant et inexistant', () {
      final guide = repository.getGuideById('guide_cycle_phases');
      expect(guide, isNotNull);
      expect(guide!.category, equals(GuideCategory.cyclePhysiology));

      final notFound = repository.getGuideById('guide_inexistant');
      expect(notFound, isNull);
    });

    test('Chaque catégorie thématique est représentée dans le catalogue', () {
      final guides = repository.getAllGuides();
      final categories = guides.map((g) => g.category).toSet();

      expect(categories.contains(GuideCategory.cyclePhysiology), isTrue);
      expect(categories.contains(GuideCategory.stiPrevention), isTrue);
      expect(categories.contains(GuideCategory.consentCommunication), isTrue);
      expect(categories.contains(GuideCategory.wellnessPleasure), isTrue);
    });

    test('Gestion des favoris avec persistance locale chiffrée', () async {
      // Par défaut aucun favori
      expect(await repository.getFavoriteIds(), isEmpty);

      // Ajouter en favori
      final added = await repository.toggleFavorite('guide_cycle_phases');
      expect(added, isTrue);
      expect(await repository.getFavoriteIds(), contains('guide_cycle_phases'));

      // Retirer du favori
      final removed = await repository.toggleFavorite('guide_cycle_phases');
      expect(removed, isFalse);
      expect(await repository.getFavoriteIds(), isNot(contains('guide_cycle_phases')));
    });
  });
}
