import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import '../security/aes_gcm_cipher.dart';

/// Couche de persistance par fichiers JSON chiffrés.
///
/// Toutes les données métier sont sérialisées en JSON puis chiffrées avec
/// AES-256-GCM avant d'être écrites sur le disque.
///
/// Les fichiers sont écrits de manière atomique (via un fichier temporaire)
/// pour limiter les risques de corruption en cas d'arrêt brutal.
class EncryptedStorage {
  const EncryptedStorage({required this.encryptionKey});

  final Uint8List encryptionKey;

  // ─── Répertoires ──────────────────────────────────────────────────────────────

  /// Répertoire privé de l'application (inaccessible depuis l'extérieur).
  static Future<Directory> get _appDir async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/${AppConstants.appDirName}');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> get _dbDir async {
    final app = await _appDir;
    final dir = Directory('${app.path}/${AppConstants.dbDirName}');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> get _exportsDir async {
    final app = await _appDir;
    final dir = Directory('${app.path}/${AppConstants.exportsDirName}');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  // ─── Lecture ──────────────────────────────────────────────────────────────────

  /// Lit et déchiffre un fichier de base de données.
  /// Retourne null si le fichier n'existe pas.
  /// Lève [StorageReadException] ou [DataCorruptionException] en cas d'erreur.
  Future<Map<String, dynamic>?> readJsonFile(String filename) async {
    try {
      final dir = await _dbDir;
      final file = File('${dir.path}/$filename');

      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      final plaintext = AesGcmCipher.decrypt(bytes, encryptionKey);
      final json = utf8.decode(plaintext);
      return jsonDecode(json) as Map<String, dynamic>;
    } on EncryptionException {
      rethrow;
    } on FormatException catch (e) {
      throw DataCorruptionException(
        'Fichier JSON invalide : $filename',
        cause: e,
      );
    } catch (e) {
      throw StorageReadException(
        'Impossible de lire le fichier : $filename',
        cause: e,
      );
    }
  }

  /// Lit et déchiffre un fichier de base de données, retourne une liste JSON.
  Future<List<dynamic>?> readJsonListFile(String filename) async {
    try {
      final dir = await _dbDir;
      final file = File('${dir.path}/$filename');

      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      final plaintext = AesGcmCipher.decrypt(bytes, encryptionKey);
      final json = utf8.decode(plaintext);
      return jsonDecode(json) as List<dynamic>;
    } on EncryptionException {
      rethrow;
    } on FormatException catch (e) {
      throw DataCorruptionException(
        'Fichier JSON liste invalide : $filename',
        cause: e,
      );
    } catch (e) {
      throw StorageReadException(
        'Impossible de lire le fichier : $filename',
        cause: e,
      );
    }
  }

  // ─── Écriture atomique ────────────────────────────────────────────────────────

  /// Chiffre et écrit un objet JSON dans un fichier de base de données.
  /// Utilise une écriture atomique via un fichier temporaire.
  Future<void> writeJsonFile(String filename, Map<String, dynamic> data) async {
    await _atomicWrite(filename, jsonEncode(data));
  }

  /// Chiffre et écrit une liste JSON dans un fichier de base de données.
  Future<void> writeJsonListFile(String filename, List<dynamic> data) async {
    await _atomicWrite(filename, jsonEncode(data));
  }

  Future<void> _atomicWrite(String filename, String jsonString) async {
    try {
      final dir = await _dbDir;
      final targetFile = File('${dir.path}/$filename');
      final tempFile = File('${dir.path}/$filename.tmp');

      final plaintext = Uint8List.fromList(utf8.encode(jsonString));
      final ciphertext = AesGcmCipher.encrypt(plaintext, encryptionKey);

      // Écriture dans le fichier temporaire d'abord
      await tempFile.writeAsBytes(ciphertext, flush: true);

      // Remplacement atomique du fichier cible
      await tempFile.rename(targetFile.path);
    } on EncryptionException {
      rethrow;
    } catch (e) {
      throw StorageWriteException(
        'Impossible d\'écrire le fichier : $filename',
        cause: e,
      );
    }
  }

  // ─── Suppression ──────────────────────────────────────────────────────────────

  /// Supprime un fichier de données spécifique.
  Future<void> deleteFile(String filename) async {
    try {
      final dir = await _dbDir;
      final file = File('${dir.path}/$filename');
      if (file.existsSync()) await file.delete();
    } catch (e) {
      throw StorageWriteException(
        'Impossible de supprimer le fichier : $filename',
        cause: e,
      );
    }
  }

  /// Supprime tous les fichiers de la base de données.
  static Future<void> deleteAllData() async {
    try {
      final dir = await _dbDir;
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      throw StorageWriteException(
        'Impossible de supprimer toutes les données.',
        cause: e,
      );
    }
  }

  // ─── Métadonnées (non chiffrées) ──────────────────────────────────────────────

  /// Lit le fichier de métadonnées (non chiffré, ne contient pas de données intimes).
  static Future<Map<String, dynamic>?> readMetadata() async {
    try {
      final dir = await _dbDir;
      final file = File('${dir.path}/${AppConstants.metadataFile}');
      if (!file.existsSync()) return null;
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Écrit les métadonnées (version du schéma, timestamps, etc.)
  static Future<void> writeMetadata(Map<String, dynamic> metadata) async {
    try {
      final dir = await _dbDir;
      final file = File('${dir.path}/${AppConstants.metadataFile}');
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(metadata),
        flush: true,
      );
    } catch (e) {
      throw StorageWriteException(
        'Impossible d\'écrire les métadonnées.',
        cause: e,
      );
    }
  }

  // ─── Sauvegarde ───────────────────────────────────────────────────────────────

  /// Retourne le répertoire d'exports.
  static Future<String> get exportsDirPath async {
    final dir = await _exportsDir;
    return dir.path;
  }

  /// Retourne le chemin de la base de données pour les opérations de sauvegarde.
  static Future<String> get dbDirPath async {
    final dir = await _dbDir;
    return dir.path;
  }
}
