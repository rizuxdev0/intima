import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/errors/app_exceptions.dart';
import 'package:intima/core/security/aes_gcm_cipher.dart';

void main() {
  group('AesGcmCipher Tests', () {
    test('Encrypt and Decrypt successfully recovers plaintext', () {
      final key = AesGcmCipher.generateKey();
      expect(key.length, 32);

      const plaintextString = 'Données intimes et hautement confidentielles d\'Intima.';
      final plaintext = Uint8List.fromList(utf8.encode(plaintextString));

      final ciphertext = AesGcmCipher.encrypt(plaintext, key);

      // Le ciphertext doit inclure le nonce de 12 octets et le tag GCM de 16 octets
      expect(ciphertext.length, greaterThan(plaintext.length + 27));

      final decrypted = AesGcmCipher.decrypt(ciphertext, key);
      final decryptedString = utf8.decode(decrypted);

      expect(decryptedString, equals(plaintextString));
    });

    test('Déchiffrement avec une clé différente lève une EncryptionException', () {
      final key1 = AesGcmCipher.generateKey();
      final key2 = AesGcmCipher.generateKey();

      final plaintext = Uint8List.fromList(utf8.encode('Secret'));
      final ciphertext = AesGcmCipher.encrypt(plaintext, key1);

      expect(
        () => AesGcmCipher.decrypt(ciphertext, key2),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('Altération des données chiffrées (tag GCM invalide) lève une EncryptionException', () {
      final key = AesGcmCipher.generateKey();
      final plaintext = Uint8List.fromList(utf8.encode('Secret'));
      final ciphertext = AesGcmCipher.encrypt(plaintext, key);

      // Altérer un octet dans le payload
      ciphertext[ciphertext.length - 1] ^= 0xFF;

      expect(
        () => AesGcmCipher.decrypt(ciphertext, key),
        throwsA(isA<EncryptionException>()),
      );
    });

    test('Conversion de clé en base64 est réversible', () {
      final key = AesGcmCipher.generateKey();
      final b64 = AesGcmCipher.keyToBase64(key);
      final recoveredKey = AesGcmCipher.keyFromBase64(b64);

      expect(recoveredKey, equals(key));
    });
  });
}

