import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/storage/storage_provider.dart';
import '../../../shared/models/app_preferences.dart';
import '../data/preferences_repository.dart';

/// Provider des préférences utilisateur.
/// Notifie tous les consommateurs lorsque les préférences changent.
class PreferencesNotifier extends AsyncNotifier<AppPreferences> {
  late PreferencesRepository _repo;

  @override
  Future<AppPreferences> build() async {
    final storage = await ref.watch(encryptedStorageProvider.future);
    _repo = PreferencesRepository(storage);
    return _repo.load();
  }

  Future<void> _updatePreferences(AppPreferences Function(AppPreferences) updater) async {
    final current = state.valueOrNull ?? const AppPreferences();
    final updated = updater(current);
    state = AsyncData(updated);
    await _repo.save(updated);
  }

  Future<void> setLocale(String locale) =>
      _updatePreferences((p) => p.copyWith(locale: locale));

  Future<void> setThemeMode(ThemeMode mode) =>
      _updatePreferences((p) => p.copyWith(themeMode: mode));

  Future<void> setBiometricEnabled(bool enabled) =>
      _updatePreferences((p) => p.copyWith(biometricEnabled: enabled));

  Future<void> setAutoLockSeconds(int seconds) =>
      _updatePreferences((p) => p.copyWith(autoLockSeconds: seconds));

  Future<void> setDiscreetMode(bool enabled) =>
      _updatePreferences((p) => p.copyWith(discreetMode: enabled));

  Future<void> setNotificationDiscretion(int level) async {
    final current = state.valueOrNull ?? const AppPreferences();
    await _updatePreferences((p) => p.copyWith(notificationDiscretion: level));

    if (current.notificationsEnabled) {
      if (current.pillReminderEnabled) {
        await NotificationService.schedulePillReminder(
          timeStr: current.pillReminderTime,
          discretionLevel: level,
        );
      }
      if (current.dailyCheckinReminderEnabled) {
        await NotificationService.scheduleDailyCheckinReminder(
          timeStr: current.dailyCheckinReminderTime,
          discretionLevel: level,
        );
      }
    }
  }

  Future<void> setOnboardingCompleted() =>
      _updatePreferences((p) => p.copyWith(onboardingCompleted: true));

  Future<void> setUsageMode(UsageMode mode) =>
      _updatePreferences((p) => p.copyWith(usageMode: mode));

  Future<void> setWeekStartsOnMonday(bool value) =>
      _updatePreferences((p) => p.copyWith(weekStartsOnMonday: value));

  Future<void> setDateFormat(String format) =>
      _updatePreferences((p) => p.copyWith(dateFormat: format));

  Future<void> setDashboardCardVisibility({
    bool? showEncounters,
    bool? showCycle,
    bool? showReminders,
  }) =>
      _updatePreferences(
        (p) => p.copyWith(
          showEncountersOnDashboard: showEncounters,
          showCycleOnDashboard: showCycle,
          showRemindersOnDashboard: showReminders,
        ),
      );

  /// Met à jour le prénom / pseudo affiché dans l'interface.
  Future<void> setUserName(String name) =>
      _updatePreferences((p) => p.copyWith(userName: name));

  /// Met à jour le genre déclaré (utilisé pour adapter le vocabulaire de l'UI).
  Future<void> setUserGender(UserGender gender) =>
      _updatePreferences((p) => p.copyWith(userGender: gender));

  /// Met à jour l'année de naissance.
  Future<void> setBirthYear(int? year) =>
      _updatePreferences((p) => p.copyWith(birthYear: year));

  /// Met à jour les objectifs de l'utilisateur (Flo style goals).
  Future<void> setGoals(List<String> goals) =>
      _updatePreferences((p) => p.copyWith(goals: goals));

  /// Met à jour la source de recommandation / découverte.
  Future<void> setReferralSource(String source) =>
      _updatePreferences((p) => p.copyWith(referralSource: source));

  /// Enregistre l'acceptation de la politique de confidentialité locale.
  Future<void> setAcceptedPrivacyPolicy(bool accepted) =>
      _updatePreferences((p) => p.copyWith(acceptedPrivacyPolicy: accepted));

  /// Configuration des notifications & rappels
  Future<void> setNotificationsEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const AppPreferences();
    await _updatePreferences((p) => p.copyWith(notificationsEnabled: enabled));

    if (enabled) {
      await NotificationService.requestPermissions();
      if (current.pillReminderEnabled) {
        await NotificationService.schedulePillReminder(
          timeStr: current.pillReminderTime,
          discretionLevel: current.notificationDiscretion,
        );
      }
      if (current.dailyCheckinReminderEnabled) {
        await NotificationService.scheduleDailyCheckinReminder(
          timeStr: current.dailyCheckinReminderTime,
          discretionLevel: current.notificationDiscretion,
        );
      }
    } else {
      await NotificationService.cancelPillReminder();
      await NotificationService.cancelDailyCheckinReminder();
      await NotificationService.cancelPeriodReminder();
    }
  }

  Future<void> setPeriodReminderDaysBefore(int days) async {
    await _updatePreferences((p) => p.copyWith(periodReminderDaysBefore: days));
  }

  Future<void> setPillReminder({bool? enabled, String? time}) async {
    final current = state.valueOrNull ?? const AppPreferences();
    final newEnabled = enabled ?? current.pillReminderEnabled;
    final newTime = time ?? current.pillReminderTime;

    await _updatePreferences((p) => p.copyWith(
          pillReminderEnabled: newEnabled,
          pillReminderTime: newTime,
        ));

    if (newEnabled && current.notificationsEnabled) {
      await NotificationService.requestPermissions();
      await NotificationService.schedulePillReminder(
        timeStr: newTime,
        discretionLevel: current.notificationDiscretion,
      );
    } else {
      await NotificationService.cancelPillReminder();
    }
  }

  Future<void> setDailyCheckinReminder({bool? enabled, String? time}) async {
    final current = state.valueOrNull ?? const AppPreferences();
    final newEnabled = enabled ?? current.dailyCheckinReminderEnabled;
    final newTime = time ?? current.dailyCheckinReminderTime;

    await _updatePreferences((p) => p.copyWith(
          dailyCheckinReminderEnabled: newEnabled,
          dailyCheckinReminderTime: newTime,
        ));

    if (newEnabled && current.notificationsEnabled) {
      await NotificationService.requestPermissions();
      await NotificationService.scheduleDailyCheckinReminder(
        timeStr: newTime,
        discretionLevel: current.notificationDiscretion,
      );
    } else {
      await NotificationService.cancelDailyCheckinReminder();
    }
  }
}

final preferencesProvider =
    AsyncNotifierProvider<PreferencesNotifier, AppPreferences>(
  PreferencesNotifier.new,
);

