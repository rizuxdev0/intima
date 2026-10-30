import 'package:flutter/material.dart';

/// Modèle des préférences utilisateur.
/// Stocké dans preferences.enc (chiffré AES-256-GCM).
class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.locale = 'fr',
    this.dateFormat = 'dd/MM/yyyy',
    this.weekStartsOnMonday = true,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
    this.autoLockSeconds = 300,
    this.hideInRecents = true,
    this.discreetMode = false,
    this.notificationDiscretion = 0,
    this.usageMode = UsageMode.full,
    this.onboardingCompleted = false,
    this.showEncountersOnDashboard = true,
    this.showCycleOnDashboard = true,
    this.showRemindersOnDashboard = true,
    this.userName = '',
    this.userGender = UserGender.notSpecified,
    this.birthYear,
    this.goals = const [],
    this.referralSource = '',
    this.acceptedPrivacyPolicy = false,
    this.periodReminderDaysBefore = 2,
    this.pillReminderEnabled = false,
    this.pillReminderTime = '08:00',
    this.dailyCheckinReminderEnabled = false,
    this.dailyCheckinReminderTime = '21:00',
  });

  final ThemeMode themeMode;
  final String locale;
  final String dateFormat;
  final bool weekStartsOnMonday;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final int autoLockSeconds;
  final bool hideInRecents;
  final bool discreetMode;

  /// 0 = discret, 1 = personnalisé, 2 = détaillé
  final int notificationDiscretion;
  final UsageMode usageMode;
  final bool onboardingCompleted;
  final bool showEncountersOnDashboard;
  final bool showCycleOnDashboard;
  final bool showRemindersOnDashboard;

  /// Prénom, surnom ou pseudo choisi par l'utilisateur (facultatif, jamais obligatoire).
  final String userName;

  /// Genre déclaré par l'utilisateur (optionnel, influence le vocabulaire de l'UI).
  final UserGender userGender;

  /// Année de naissance (facultative, pour estimations médicales et physiologiques).
  final int? birthYear;

  /// Objectifs personnels choisis (ex: cycle, intimité, santé, contraception, fertilité).
  final List<String> goals;

  /// Comment l'utilisateur a découvert l'application (Flo style onboarding).
  final String referralSource;

  /// Acceptation explicite de la politique de confidentialité locale et des conditions.
  final bool acceptedPrivacyPolicy;

  /// Rappel préventif avant les règles (en jours d'avance).
  final int periodReminderDaysBefore;

  /// Rappel prise de pilule / contraception quotidienne.
  final bool pillReminderEnabled;
  final String pillReminderTime;

  /// Rappel journal intime / check-in quotidien du soir.
  final bool dailyCheckinReminderEnabled;
  final String dailyCheckinReminderTime;

  AppPreferences copyWith({
    ThemeMode? themeMode,
    String? locale,
    String? dateFormat,
    bool? weekStartsOnMonday,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    int? autoLockSeconds,
    bool? hideInRecents,
    bool? discreetMode,
    int? notificationDiscretion,
    UsageMode? usageMode,
    bool? onboardingCompleted,
    bool? showEncountersOnDashboard,
    bool? showCycleOnDashboard,
    bool? showRemindersOnDashboard,
    String? userName,
    UserGender? userGender,
    int? birthYear,
    List<String>? goals,
    String? referralSource,
    bool? acceptedPrivacyPolicy,
    int? periodReminderDaysBefore,
    bool? pillReminderEnabled,
    String? pillReminderTime,
    bool? dailyCheckinReminderEnabled,
    String? dailyCheckinReminderTime,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      dateFormat: dateFormat ?? this.dateFormat,
      weekStartsOnMonday: weekStartsOnMonday ?? this.weekStartsOnMonday,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockSeconds: autoLockSeconds ?? this.autoLockSeconds,
      hideInRecents: hideInRecents ?? this.hideInRecents,
      discreetMode: discreetMode ?? this.discreetMode,
      notificationDiscretion: notificationDiscretion ?? this.notificationDiscretion,
      usageMode: usageMode ?? this.usageMode,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      showEncountersOnDashboard: showEncountersOnDashboard ?? this.showEncountersOnDashboard,
      showCycleOnDashboard: showCycleOnDashboard ?? this.showCycleOnDashboard,
      showRemindersOnDashboard: showRemindersOnDashboard ?? this.showRemindersOnDashboard,
      userName: userName ?? this.userName,
      userGender: userGender ?? this.userGender,
      birthYear: birthYear ?? this.birthYear,
      goals: goals ?? this.goals,
      referralSource: referralSource ?? this.referralSource,
      acceptedPrivacyPolicy: acceptedPrivacyPolicy ?? this.acceptedPrivacyPolicy,
      periodReminderDaysBefore: periodReminderDaysBefore ?? this.periodReminderDaysBefore,
      pillReminderEnabled: pillReminderEnabled ?? this.pillReminderEnabled,
      pillReminderTime: pillReminderTime ?? this.pillReminderTime,
      dailyCheckinReminderEnabled: dailyCheckinReminderEnabled ?? this.dailyCheckinReminderEnabled,
      dailyCheckinReminderTime: dailyCheckinReminderTime ?? this.dailyCheckinReminderTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.index,
        'locale': locale,
        'dateFormat': dateFormat,
        'weekStartsOnMonday': weekStartsOnMonday,
        'notificationsEnabled': notificationsEnabled,
        'biometricEnabled': biometricEnabled,
        'autoLockSeconds': autoLockSeconds,
        'hideInRecents': hideInRecents,
        'discreetMode': discreetMode,
        'notificationDiscretion': notificationDiscretion,
        'usageMode': usageMode.index,
        'onboardingCompleted': onboardingCompleted,
        'showEncountersOnDashboard': showEncountersOnDashboard,
        'showCycleOnDashboard': showCycleOnDashboard,
        'showRemindersOnDashboard': showRemindersOnDashboard,
        'userName': userName,
        'userGender': userGender.index,
        'birthYear': birthYear,
        'goals': goals,
        'referralSource': referralSource,
        'acceptedPrivacyPolicy': acceptedPrivacyPolicy,
        'periodReminderDaysBefore': periodReminderDaysBefore,
        'pillReminderEnabled': pillReminderEnabled,
        'pillReminderTime': pillReminderTime,
        'dailyCheckinReminderEnabled': dailyCheckinReminderEnabled,
        'dailyCheckinReminderTime': dailyCheckinReminderTime,
      };

  factory AppPreferences.fromJson(Map<String, dynamic> json) => AppPreferences(
        themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
        locale: json['locale'] as String? ?? 'fr',
        dateFormat: json['dateFormat'] as String? ?? 'dd/MM/yyyy',
        weekStartsOnMonday: json['weekStartsOnMonday'] as bool? ?? true,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        biometricEnabled: json['biometricEnabled'] as bool? ?? false,
        autoLockSeconds: json['autoLockSeconds'] as int? ?? 300,
        hideInRecents: json['hideInRecents'] as bool? ?? true,
        discreetMode: json['discreetMode'] as bool? ?? false,
        notificationDiscretion: json['notificationDiscretion'] as int? ?? 0,
        usageMode: UsageMode.values[json['usageMode'] as int? ?? 3],
        onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
        showEncountersOnDashboard: json['showEncountersOnDashboard'] as bool? ?? true,
        showCycleOnDashboard: json['showCycleOnDashboard'] as bool? ?? true,
        showRemindersOnDashboard: json['showRemindersOnDashboard'] as bool? ?? true,
        userName: json['userName'] as String? ?? '',
        userGender: UserGender.values[json['userGender'] as int? ?? 0],
        birthYear: json['birthYear'] as int?,
        goals: (json['goals'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        referralSource: json['referralSource'] as String? ?? '',
        acceptedPrivacyPolicy: json['acceptedPrivacyPolicy'] as bool? ?? false,
        periodReminderDaysBefore: json['periodReminderDaysBefore'] as int? ?? 2,
        pillReminderEnabled: json['pillReminderEnabled'] as bool? ?? false,
        pillReminderTime: json['pillReminderTime'] as String? ?? '08:00',
        dailyCheckinReminderEnabled: json['dailyCheckinReminderEnabled'] as bool? ?? false,
        dailyCheckinReminderTime: json['dailyCheckinReminderTime'] as String? ?? '21:00',
      );

  /// Indique si l'utilisateur a activé le suivi menstruel / cycle dans ses préférences.
  bool get hasMenstrualTracking {
    if (usageMode == UsageMode.personal || usageMode == UsageMode.relationships) {
      return false;
    }
    if (goals.isNotEmpty && !goals.contains('cycle')) {
      return false;
    }
    return true;
  }

  /// Indique si l'utilisateur suit sa vie relationnelle et ses rencontres intimes.
  bool get hasRelationalTracking {
    if (usageMode == UsageMode.personal || usageMode == UsageMode.menstrual) {
      return false;
    }
    if (goals.isNotEmpty && !goals.contains('intimacy')) {
      return false;
    }
    return true;
  }

  /// Indique si le suivi de la santé sexuelle et des dépistages IST est actif.
  bool get hasSexualHealthTracking =>
      goals.isEmpty || goals.contains('health') || hasRelationalTracking;

  /// Indique si le journal intime personnel est activé.
  bool get hasJournalTracking =>
      goals.isEmpty ||
      goals.contains('journal') ||
      usageMode == UsageMode.personal ||
      usageMode == UsageMode.full;
}

enum UsageMode {
  personal,
  relationships,
  menstrual,
  full,
}

/// Genre déclaré par l'utilisateur, utilisé uniquement pour adapter
/// le vocabulaire de l'interface (accords, termes médicaux adaptés).
enum UserGender {
  notSpecified,
  female,
  male,
  nonBinary,
}
