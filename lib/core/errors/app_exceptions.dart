/// Hiérarchie des erreurs de l'application INTIMA.
/// Permet une gestion typée des exceptions sans dépendance à des libs externes.
library;

/// Classe de base pour toutes les erreurs métier de l'application.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

// ─── Erreurs de stockage ──────────────────────────────────────────────────────

/// Impossible de lire un fichier de données.
final class StorageReadException extends AppException {
  const StorageReadException(super.message, {super.cause});
}

/// Impossible d'écrire un fichier de données.
final class StorageWriteException extends AppException {
  const StorageWriteException(super.message, {super.cause});
}

/// Fichier de données corrompu ou invalide.
final class DataCorruptionException extends AppException {
  const DataCorruptionException(super.message, {super.cause});
}

/// Erreur lors d'une migration de schéma.
final class MigrationException extends AppException {
  const MigrationException(super.message, {super.cause});
}

// ─── Erreurs de sécurité ──────────────────────────────────────────────────────

/// Erreur de chiffrement ou de déchiffrement.
final class EncryptionException extends AppException {
  const EncryptionException(super.message, {super.cause});
}

/// Code PIN incorrect.
final class IncorrectPinException extends AppException {
  const IncorrectPinException(super.message) : super();
}

/// Trop de tentatives d'authentification échouées.
final class TooManyAttemptsException extends AppException {
  const TooManyAttemptsException(super.message, {this.lockoutUntil});

  final DateTime? lockoutUntil;
}

/// Biométrie non disponible ou non configurée.
final class BiometricUnavailableException extends AppException {
  const BiometricUnavailableException(super.message) : super();
}

/// Authentification biométrique refusée par l'utilisateur.
final class BiometricDeniedException extends AppException {
  const BiometricDeniedException(super.message) : super();
}

// ─── Erreurs de sauvegarde ────────────────────────────────────────────────────

/// Fichier de sauvegarde invalide ou corrompu.
final class BackupIntegrityException extends AppException {
  const BackupIntegrityException(super.message, {super.cause});
}

/// Erreur lors de la création ou la restauration d'une sauvegarde.
final class BackupException extends AppException {
  const BackupException(super.message, {super.cause});
}

// ─── Erreurs de notification ──────────────────────────────────────────────────

/// Erreur lors de la programmation d'une notification.
final class NotificationException extends AppException {
  const NotificationException(super.message, {super.cause});
}

// ─── Erreur générique ─────────────────────────────────────────────────────────

/// Erreur inattendue non catégorisée.
final class UnexpectedException extends AppException {
  const UnexpectedException(super.message, {super.cause});
}
