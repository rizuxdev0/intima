/// Constantes globales de l'application INTIMA.
/// Centralise tous les identifiants, timeouts et valeurs fixes.
library;

class AppConstants {
  AppConstants._();

  // ─── Identité ────────────────────────────────────────────────────────────────
  static const String appName = 'Intima';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.intima.intima';

  // ─── Sécurité ─────────────────────────────────────────────────────────────────
  static const int pinLength = 6;
  static const int maxPinAttempts = 5;
  static const int lockoutDurationSeconds = 60;
  static const String secureStorageKeyName = 'intima_encryption_key';
  static const String secureStoragePinHashKey = 'intima_pin_hash';
  static const String secureStoragePinSaltKey = 'intima_pin_salt';
  static const String secureStorageDuressPinHashKey = 'intima_duress_pin_hash';
  static const String secureStorageDuressPinSaltKey = 'intima_duress_pin_salt';

  // ─── Stockage ─────────────────────────────────────────────────────────────────
  static const String appDirName = 'intima_data';
  static const String dbDirName = 'database';
  static const String exportsDirName = 'exports';
  static const String logsDirName = 'logs';

  static const String profileFile = 'profile.enc';
  static const String partnersFile = 'partners.enc';
  static const String encountersFile = 'encounters.enc';
  static const String menstrualCyclesFile = 'menstrual_cycles.enc';
  static const String symptomsFile = 'symptoms.enc';
  static const String remindersFile = 'reminders.enc';
  static const String journalEntriesFile = 'journal_entries.enc';
  static const String journalCategoriesFile = 'journal_categories.enc';
  static const String journalRemindersFile = 'journal_reminders.enc';
  static const String sexualHealthFile = 'sexual_health.enc';
  static const String preferencesFile = 'preferences.enc';
  static const String metadataFile = 'metadata.json';
  static const String configFile = 'app_config.json';

  // ─── Schéma de données ────────────────────────────────────────────────────────
  static const int currentSchemaVersion = 1;
  static const String backupExtension = '.intima.enc';
  static const String backupMagicHeader = 'INTIMA_BACKUP_V1';

  // ─── Auto-verrouillage ────────────────────────────────────────────────────────
  static const List<int> autoLockOptions = [0, 30, 60, 300, 600];

  // ─── Cycle menstruel ──────────────────────────────────────────────────────────
  /// Durée de cycle par défaut utilisée lorsque les données sont insuffisantes.
  static const int defaultCycleDays = 28;

  /// Nombre minimum de cycles requis pour une estimation fiable.
  static const int minCyclesForReliableEstimate = 3;

  /// Jours avant l'ovulation estimée pour la fenêtre de fertilité.
  static const int fertilityDaysBefore = 5;

  /// Jours après l'ovulation estimée inclus dans la fenêtre.
  static const int fertilityDaysAfter = 1;

  // ─── Pagination ───────────────────────────────────────────────────────────────
  static const int encountersPageSize = 30;
  static const int partnersPageSize = 50;
  static const int remindersPageSize = 30;

  // ─── Notifications ────────────────────────────────────────────────────────────
  static const String notificationChannelId = 'intima_reminders';
  static const String notificationChannelName = 'Intima Reminders';
  static const int notificationMaxScheduled = 64;
  static const int testNotificationId = 9999;
  static const int pillNotificationId = 8801;
  static const int checkinNotificationId = 8802;
  static const int periodNotificationId = 8803;

  // ─── UI ───────────────────────────────────────────────────────────────────────
  static const double cardBorderRadius = 16.0;
  static const double dialogBorderRadius = 20.0;
  static const double buttonBorderRadius = 12.0;
  static const double minTouchTarget = 48.0;
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration shortAnimDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimDuration = Duration(milliseconds: 350);
  static const Duration longAnimDuration = Duration(milliseconds: 500);
}
