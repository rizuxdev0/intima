import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';
import 'aes_gcm_cipher.dart';

/// Résultat détaillé de la vérification d'un code PIN (normal ou leurre).
enum PinVerificationResult {
  success,
  duress,
  incorrect,
}

/// Service de gestion des secrets de sécurité de l'application.
///
/// Responsabilités :
/// - Générer et stocker la clé de chiffrement AES-256 dans le keystore natif.
/// - Gérer le PIN (stocké sous forme de hash PBKDF2, jamais en clair).
/// - Compter et bloquer les tentatives d'authentification échouées.
class SecurityService {
  SecurityService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ─── Clé de chiffrement ───────────────────────────────────────────────────────

  /// Retourne la clé AES-256 existante, ou en génère une nouvelle.
  /// Lève [EncryptionException] en cas d'erreur de stockage.
  static Future<Uint8List> getOrCreateEncryptionKey() async {
    try {
      final existing = await _storage.read(key: AppConstants.secureStorageKeyName);
      if (existing != null) {
        return AesGcmCipher.keyFromBase64(existing);
      }
      final newKey = AesGcmCipher.generateKey();
      await _storage.write(
        key: AppConstants.secureStorageKeyName,
        value: AesGcmCipher.keyToBase64(newKey),
      );
      return newKey;
    } catch (e) {
      throw EncryptionException(
        'Impossible d\'accéder à la clé de chiffrement.',
        cause: e,
      );
    }
  }

  /// Retourne la clé de chiffrement existante, ou null si aucune n'existe.
  static Future<Uint8List?> getEncryptionKey() async {
    final existing = await _storage.read(key: AppConstants.secureStorageKeyName);
    if (existing == null) return null;
    return AesGcmCipher.keyFromBase64(existing);
  }

  /// Supprime la clé de chiffrement (lors de la réinitialisation complète).
  static Future<void> deleteEncryptionKey() async {
    await _storage.delete(key: AppConstants.secureStorageKeyName);
  }

  // ─── Gestion du PIN ───────────────────────────────────────────────────────────

  /// Enregistre le PIN après le hachage PBKDF2 avec sel aléatoire.
  /// Le PIN en clair n'est jamais stocké.
  static Future<void> setPin(String pin) async {
    if (pin.length != AppConstants.pinLength) {
      throw const IncorrectPinException('Longueur de PIN invalide.');
    }

    final salt = _randomBytes(16);
    final hash = _pbkdf2(pin, salt);

    await _storage.write(
      key: AppConstants.secureStoragePinHashKey,
      value: base64.encode(hash),
    );
    await _storage.write(
      key: AppConstants.secureStoragePinSaltKey,
      value: base64.encode(salt),
    );
    // Réinitialiser le compteur de tentatives lors du changement de PIN
    await _resetAttemptCount();
  }

  /// Vérifie le PIN fourni par l'utilisateur.
  /// Lève [IncorrectPinException] si le PIN est incorrect.
  /// Lève [TooManyAttemptsException] si le compte est verrouillé.
  static Future<bool> verifyPin(String pin) async {
    final result = await verifyPinDetailed(pin);
    return result == PinVerificationResult.success || result == PinVerificationResult.duress;
  }

  /// Vérifie le PIN et identifie s'il s'agit du vrai code ou du code leurre (duress).
  static Future<PinVerificationResult> verifyPinDetailed(String pin) async {
    await _checkLockout();

    final storedHash = await _storage.read(key: AppConstants.secureStoragePinHashKey);
    final storedSalt = await _storage.read(key: AppConstants.secureStoragePinSaltKey);

    if (storedHash == null || storedSalt == null) {
      throw const IncorrectPinException('Aucun PIN configuré.');
    }

    final salt = base64.decode(storedSalt);
    final computedHash = _pbkdf2(pin, salt);
    final expectedHash = base64.decode(storedHash);

    // 1. Vérifier si c'est le PIN principal
    final isPrimaryCorrect = _constantTimeEqual(computedHash, expectedHash);
    if (isPrimaryCorrect) {
      await _resetAttemptCount();
      return PinVerificationResult.success;
    }

    // 2. Vérifier si un code PIN leurre est configuré et correspond
    final duressHash = await _storage.read(key: AppConstants.secureStorageDuressPinHashKey);
    final duressSalt = await _storage.read(key: AppConstants.secureStorageDuressPinSaltKey);

    if (duressHash != null && duressSalt != null) {
      final dSalt = base64.decode(duressSalt);
      final dComputedHash = _pbkdf2(pin, dSalt);
      final dExpectedHash = base64.decode(duressHash);

      final isDuressCorrect = _constantTimeEqual(dComputedHash, dExpectedHash);
      if (isDuressCorrect) {
        await _resetAttemptCount();
        return PinVerificationResult.duress;
      }
    }

    // 3. Ni le vrai PIN ni le leurre ne correspondent -> échec
    await _incrementAttemptCount();
    final remaining = await _remainingAttempts();
    if (remaining <= 0) {
      await _applyLockout();
      throw TooManyAttemptsException(
        'Compte verrouillé.',
        lockoutUntil: DateTime.now().add(
          const Duration(seconds: AppConstants.lockoutDurationSeconds),
        ),
      );
    }
    return PinVerificationResult.incorrect;
  }

  // ─── Code PIN Leurre (Duress PIN) ─────────────────────────────────────────────

  /// Configure ou met à jour le code PIN leurre.
  static Future<void> setDuressPin(String pin) async {
    if (pin.length != AppConstants.pinLength) {
      throw const IncorrectPinException('Longueur de PIN invalide.');
    }

    final salt = _randomBytes(16);
    final hash = _pbkdf2(pin, salt);

    await _storage.write(
      key: AppConstants.secureStorageDuressPinHashKey,
      value: base64.encode(hash),
    );
    await _storage.write(
      key: AppConstants.secureStorageDuressPinSaltKey,
      value: base64.encode(salt),
    );
  }

  /// Indique si un code PIN leurre a été configuré par l'utilisateur.
  static Future<bool> hasDuressPinConfigured() async {
    final hash = await _storage.read(key: AppConstants.secureStorageDuressPinHashKey);
    return hash != null;
  }

  /// Supprime le code PIN leurre.
  static Future<void> deleteDuressPin() async {
    await _storage.delete(key: AppConstants.secureStorageDuressPinHashKey);
    await _storage.delete(key: AppConstants.secureStorageDuressPinSaltKey);
  }

  /// Indique si un PIN a été configuré.
  static Future<bool> hasPinConfigured() async {
    final hash = await _storage.read(key: AppConstants.secureStoragePinHashKey);
    return hash != null;
  }

  /// Supprime le PIN (lors de la réinitialisation complète).
  static Future<void> deletePin() async {
    await _storage.delete(key: AppConstants.secureStoragePinHashKey);
    await _storage.delete(key: AppConstants.secureStoragePinSaltKey);
    await _resetAttemptCount();
  }

  /// Supprime toutes les données sensibles (clé + PIN).
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // ─── Implémentation interne ───────────────────────────────────────────────────

  static const String _attemptKey = 'intima_pin_attempts';
  static const String _lockoutKey = 'intima_pin_lockout_until';

  static Future<void> _checkLockout() async {
    final lockoutStr = await _storage.read(key: _lockoutKey);
    if (lockoutStr == null) return;

    final lockoutUntil = DateTime.tryParse(lockoutStr);
    if (lockoutUntil == null) return;

    if (DateTime.now().isBefore(lockoutUntil)) {
      final seconds = lockoutUntil.difference(DateTime.now()).inSeconds;
      throw TooManyAttemptsException(
        'Compte verrouillé pour encore $seconds secondes.',
        lockoutUntil: lockoutUntil,
      );
    }
    // Verrouillage expiré, réinitialiser
    await _storage.delete(key: _lockoutKey);
    await _resetAttemptCount();
  }

  static Future<int> _remainingAttempts() async {
    final countStr = await _storage.read(key: _attemptKey);
    final count = int.tryParse(countStr ?? '0') ?? 0;
    return AppConstants.maxPinAttempts - count;
  }

  static Future<void> _incrementAttemptCount() async {
    final countStr = await _storage.read(key: _attemptKey);
    final count = int.tryParse(countStr ?? '0') ?? 0;
    await _storage.write(key: _attemptKey, value: '${count + 1}');
  }

  static Future<void> _resetAttemptCount() async {
    await _storage.delete(key: _attemptKey);
    await _storage.delete(key: _lockoutKey);
  }

  static Future<void> _applyLockout() async {
    final until = DateTime.now().add(
      const Duration(seconds: AppConstants.lockoutDurationSeconds),
    );
    await _storage.write(key: _lockoutKey, value: until.toIso8601String());
  }

  /// PBKDF2 avec HMAC-SHA256 pour dériver un hash sécurisé depuis le PIN.
  static Uint8List _pbkdf2(String pin, Uint8List salt) {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, 100000, 32));
    return pbkdf2.process(Uint8List.fromList(utf8.encode(pin)));
  }

  /// Comparaison en temps constant pour éviter les timing attacks.
  static bool _constantTimeEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }

  static Uint8List _randomBytes(int length) {
    final rng = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
    rng.seed(KeyParameter(Uint8List.fromList(seeds)));
    return rng.nextBytes(length);
  }
}
