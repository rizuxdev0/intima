import '../../../core/constants/app_constants.dart';
import '../../../core/storage/encrypted_storage.dart';
import '../../../shared/models/app_preferences.dart';

/// Repository de persistance des préférences utilisateur.
class PreferencesRepository {
  const PreferencesRepository(this._storage);
  final EncryptedStorage _storage;

  Future<AppPreferences> load() async {
    final json = await _storage.readJsonFile(AppConstants.preferencesFile);
    if (json == null) return const AppPreferences();
    return AppPreferences.fromJson(json);
  }

  Future<void> save(AppPreferences prefs) async {
    await _storage.writeJsonFile(AppConstants.preferencesFile, prefs.toJson());
  }
}

