import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../errors/app_exceptions.dart';

/// Service de chiffrement AES-256-GCM pour INTIMA.
///
/// Chaque opération de chiffrement génère un nonce aléatoire de 12 octets.
/// Le format du fichier chiffré est :
///   [nonce (12 bytes)] + [ciphertext + GCM tag (16 bytes)]
///
/// Le tag d'authentification GCM garantit l'intégrité des données.
/// Toute altération du fichier déclenche une [EncryptionException].
class AesGcmCipher {
  AesGcmCipher._();

  static const int _nonceLength = 12; // 96 bits recommandé pour GCM
  static const int _keyLength = 32; // 256 bits
  static const int _tagLength = 16; // 128 bits GCM tag

  /// Chiffre [plaintext] avec la clé [key] (32 octets).
  /// Retourne les octets : [nonce | ciphertext+tag].
  static Uint8List encrypt(Uint8List plaintext, Uint8List key) {
    _validateKey(key);

    final nonce = _randomBytes(_nonceLength);
    final params = AEADParameters(
      KeyParameter(key),
      _tagLength * 8, // tag length en bits
      nonce,
      Uint8List(0), // additional authenticated data vide
    );

    final cipher = GCMBlockCipher(AESEngine())..init(true, params);

    final ciphertext = cipher.process(plaintext);

    // Concaténer nonce + ciphertext (avec tag intégré par pointycastle)
    final result = Uint8List(_nonceLength + ciphertext.length);
    result.setRange(0, _nonceLength, nonce);
    result.setRange(_nonceLength, result.length, ciphertext);
    return result;
  }

  /// Déchiffre [cipherData] (format [nonce | ciphertext+tag]) avec la clé [key].
  /// Lève [EncryptionException] si les données sont altérées.
  static Uint8List decrypt(Uint8List cipherData, Uint8List key) {
    _validateKey(key);

    if (cipherData.length < _nonceLength + _tagLength) {
      throw const EncryptionException(
        'Données chiffrées trop courtes pour contenir nonce + tag.',
      );
    }

    final nonce = cipherData.sublist(0, _nonceLength);
    final ciphertext = cipherData.sublist(_nonceLength);

    final params = AEADParameters(
      KeyParameter(key),
      _tagLength * 8,
      nonce,
      Uint8List(0),
    );

    final cipher = GCMBlockCipher(AESEngine())..init(false, params);

    try {
      return cipher.process(ciphertext);
    } on InvalidCipherTextException catch (e) {
      // GCM tag mismatch → données corrompues ou clé incorrecte
      throw EncryptionException(
        'Échec de l\'authentification GCM : données corrompues ou clé incorrecte.',
        cause: e,
      );
    }
  }

  /// Génère une clé AES-256 cryptographiquement sûre.
  static Uint8List generateKey() => _randomBytes(_keyLength);

  /// Encode une clé en Base64 pour stockage dans flutter_secure_storage.
  static String keyToBase64(Uint8List key) => base64.encode(key);

  /// Décode une clé depuis sa représentation Base64.
  static Uint8List keyFromBase64(String b64) => base64.decode(b64);

  // ─── Privé ────────────────────────────────────────────────────────────────────

  static void _validateKey(Uint8List key) {
    if (key.length != _keyLength) {
      throw EncryptionException(
        'Longueur de clé invalide : ${key.length} octets (attendu : $_keyLength).',
      );
    }
  }

  static Uint8List _randomBytes(int length) {
    final rng = FortunaRandom();
    final seedSource = Random.secure();
    final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
    rng.seed(KeyParameter(Uint8List.fromList(seeds)));
    return rng.nextBytes(length);
  }
}
