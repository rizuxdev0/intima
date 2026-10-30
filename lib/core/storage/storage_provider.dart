import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../security/security_service.dart';
import '../storage/encrypted_storage.dart';

part 'storage_provider.g.dart';

/// Provider de l'instance EncryptedStorage initialisée avec la clé de chiffrement.
/// Ce provider est initialisé lors du bootstrap et injecté via ProviderScope overrides.
@riverpod
Future<EncryptedStorage> encryptedStorage(Ref ref) async {
  final key = await SecurityService.getOrCreateEncryptionKey();
  return EncryptedStorage(encryptionKey: key);
}

