// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, invalid_use_of_internal_member, deprecated_member_use

part of 'storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$encryptedStorageHash() => r'encryptedStorageProvider';

/// Provider de l'instance EncryptedStorage initialisée avec la clé de chiffrement.
@ProviderFor(encryptedStorage)
final encryptedStorageProvider = FutureProvider<EncryptedStorage>.internal(
  encryptedStorage,
  name: r'encryptedStorageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$encryptedStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EncryptedStorageRef = FutureProviderRef<EncryptedStorage>;

