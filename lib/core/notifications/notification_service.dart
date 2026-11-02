import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';

/// Service de notifications locales pour INTIMA.
///
/// Toutes les notifications fonctionnent entièrement hors ligne.
/// Dispose d'actions interactives sous la notification (ex: « Fait / Pris », « Rappeler dans 10 min »)
/// et d'une gestion intelligente du niveau de discrétion.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Actions rapides Android sous la notification
  static const List<AndroidNotificationAction> _defaultActions = [
    AndroidNotificationAction(
      'action_done',
      '✓ Fait / Pris',
      showsUserInterface: false,
      cancelNotification: true,
    ),
    AndroidNotificationAction(
      'action_snooze_10',
      '⏱ Rappeler dans 10 min',
      showsUserInterface: false,
      cancelNotification: true,
    ),
  ];

  // ─── Initialisation ───────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('[NotificationService] Timezone init warning: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration des catégories avec actions interactives pour iOS
    final darwinNotificationCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        'REMINDER_ACTIONS',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('action_done', '✓ Fait / Pris'),
          DarwinNotificationAction.plain('action_snooze_10', '⏱ Rappeler dans 10 min'),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      ),
    ];

    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: darwinNotificationCategories,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    // Enregistrement explicite du canal de notification pour Android 8.0+
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      const channel = AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: 'Rappels confidentiels et alertes de santé Intima',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      await androidImpl.createNotificationChannel(channel);
    }

    _initialized = true;
    debugPrint('[NotificationService] Initialisé avec succès.');
  }

  /// Demande les permissions de notification à l'utilisateur.
  /// Retourne true si les permissions sont accordées.
  static Future<bool> requestPermissions() async {
    if (!_initialized) await initialize();

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool granted = false;

    if (android != null) {
      // 1. Vérifier si les notifications sont déjà autorisées au niveau système
      final areEnabled = await android.areNotificationsEnabled();
      if (areEnabled == true) {
        // Demande d'alarmes exactes pour Android 14+ si supporté
        try {
          await android.requestExactAlarmsPermission();
        } catch (_) {}
        return true;
      }

      // 2. Si pas encore accordé, déclencher la boîte de dialogue système (Android 13+)
      final result = await android.requestNotificationsPermission();
      granted = result ?? false;

      // Si accordé, demander également la permission pour les alarmes exactes
      if (granted) {
        try {
          await android.requestExactAlarmsPermission();
        } catch (_) {}
      }
    } else if (ios != null) {
      final result = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = result ?? false;
    }

    return granted;
  }

  // ─── Planification ────────────────────────────────────────────────────────────

  /// Planifie une notification locale avec actions interactives sous la notification.
  /// Le titre affiché dépend du [discretionLevel] :
  /// - 0 (discret) : titre générique
  /// - 1 (personnalisé) : titre défini par l'utilisateur
  /// - 2 (détaillé) : contenu complet
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    int discretionLevel = 0,
    bool enableActions = true,
  }) async {
    if (!_initialized) await initialize();

    final displayTitle = discretionLevel == 0 ? AppConstants.appName : title;
    final displayBody = discretionLevel == 0 ? 'Tu as un rappel personnel.' : body;

    final androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: 'Rappels confidentiels et alertes de santé Intima',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF88293E),
      showWhen: true,
      enableVibration: true,
      playSound: true,
      actions: enableActions ? _defaultActions : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: enableActions ? 'REMINDER_ACTIONS' : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final targetDate = _toTZDateTime(scheduledDate);

    try {
      // Tentative d'alarme exacte en premier lieu
      await _plugin.zonedSchedule(
        id,
        displayTitle,
        displayBody,
        targetDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: displayBody,
      );
      debugPrint('[NotificationService] Notification $id programmée à $targetDate (exact)');
    } catch (e) {
      debugPrint('[NotificationService] Échec alarme exacte ($e), repli sur inexact...');
      // Repli immédiat sur alarme inexacte pour ne jamais échouer sur Android 14+
      try {
        await _plugin.zonedSchedule(
          id,
          displayTitle,
          displayBody,
          targetDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: displayBody,
        );
        debugPrint('[NotificationService] Notification $id programmée à $targetDate (inexact)');
      } catch (fallbackError) {
        debugPrint('[NotificationService] Erreur irrécupérable de planification: $fallbackError');
        throw NotificationException(
          'Impossible de planifier la notification.',
          cause: fallbackError,
        );
      }
    }
  }

  /// Annule une notification planifiée par son identifiant.
  static Future<void> cancelNotification(int id) async {
    if (!_initialized) await initialize();
    await _plugin.cancel(id);
    debugPrint('[NotificationService] Notification $id annulée.');
  }

  /// Planifie une notification répétée quotidiennement à une heure fixe.
  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    int discretionLevel = 0,
    bool enableActions = true,
  }) async {
    if (!_initialized) await initialize();

    final displayTitle = discretionLevel == 0 ? AppConstants.appName : title;
    final displayBody = discretionLevel == 0 ? 'Tu as un rappel personnel.' : body;

    final androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: 'Rappels confidentiels et alertes de santé Intima',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF88293E),
      showWhen: true,
      enableVibration: true,
      playSound: true,
      actions: enableActions ? _defaultActions : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: enableActions ? 'REMINDER_ACTIONS' : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final targetTZ = tz.TZDateTime(
      tz.local,
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledDate.hour,
      scheduledDate.minute,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        displayTitle,
        displayBody,
        targetTZ,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: displayBody,
      );
      debugPrint('[NotificationService] Rappel récurrent $id programmé à ${hour}h${minute} (exact)');
    } catch (e) {
      debugPrint('[NotificationService] Repli sur alarme inexacte pour récurrent $id: $e');
      try {
        await _plugin.zonedSchedule(
          id,
          displayTitle,
          displayBody,
          targetTZ,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: displayBody,
        );
      } catch (fallbackError) {
        debugPrint('[NotificationService] Erreur alarme récurrente: $fallbackError');
      }
    }
  }

  /// Planifie ou met à jour le rappel quotidien de pilule/contraception.
  static Future<void> schedulePillReminder({
    required String timeStr,
    int discretionLevel = 0,
  }) async {
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts.first) ?? 8;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    await cancelNotification(AppConstants.pillNotificationId);
    await scheduleDailyNotification(
      id: AppConstants.pillNotificationId,
      title: 'Rappel de contraception',
      body: 'Il est l\'heure de votre prise habituelle.',
      hour: hour,
      minute: minute,
      discretionLevel: discretionLevel,
      enableActions: true,
    );
  }

  /// Annule le rappel de pilule.
  static Future<void> cancelPillReminder() async {
    await cancelNotification(AppConstants.pillNotificationId);
  }

  /// Planifie ou met à jour le rappel quotidien du journal intime du soir.
  static Future<void> scheduleDailyCheckinReminder({
    required String timeStr,
    int discretionLevel = 0,
  }) async {
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts.first) ?? 21;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    await cancelNotification(AppConstants.checkinNotificationId);
    await scheduleDailyNotification(
      id: AppConstants.checkinNotificationId,
      title: 'Journal Intime du soir',
      body: 'Prenez quelques instants pour noter vos ressentis du jour.',
      hour: hour,
      minute: minute,
      discretionLevel: discretionLevel,
      enableActions: true,
    );
  }

  /// Annule le rappel du journal du soir.
  static Future<void> cancelDailyCheckinReminder() async {
    await cancelNotification(AppConstants.checkinNotificationId);
  }

  /// Planifie l'alerte anticipée de début de règles.
  static Future<void> schedulePeriodReminder({
    required DateTime estimatedStartDate,
    required int daysBefore,
    int discretionLevel = 0,
  }) async {
    await cancelNotification(AppConstants.periodNotificationId);

    final alertDate = estimatedStartDate.subtract(Duration(days: daysBefore));
    final scheduledDate = DateTime(alertDate.year, alertDate.month, alertDate.day, 9, 0);

    if (scheduledDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: AppConstants.periodNotificationId,
        title: 'Suivi de cycle',
        body: 'Vos règles sont estimées dans $daysBefore jour(s).',
        scheduledDate: scheduledDate,
        discretionLevel: discretionLevel,
        enableActions: true,
      );
    }
  }

  /// Annule l'alerte de règles.
  static Future<void> cancelPeriodReminder() async {
    await cancelNotification(AppConstants.periodNotificationId);
  }

  /// Affiche immédiatement une notification locale (idéal pour tester).
  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    int discretionLevel = 0,
    bool enableActions = true,
  }) async {
    if (!_initialized) await initialize();

    final displayTitle = discretionLevel == 0 ? AppConstants.appName : title;
    final displayBody = discretionLevel == 0 ? 'Tu as un rappel personnel.' : body;

    final androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: 'Rappels confidentiels et alertes de santé Intima',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF88293E),
      showWhen: true,
      enableVibration: true,
      playSound: true,
      actions: enableActions ? _defaultActions : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: enableActions ? 'REMINDER_ACTIONS' : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      displayTitle,
      displayBody,
      details,
      payload: displayBody,
    );
    debugPrint('[NotificationService] Notification immédiate $id affichée avec actions.');
  }

  /// Annule toutes les notifications planifiées.
  static Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    await _plugin.cancelAll();
    debugPrint('[NotificationService] Toutes les notifications ont été annulées.');
  }

  /// Retourne la liste des notifications en attente.
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return _plugin.pendingNotificationRequests();
  }

  // ─── Actions et Réponses ──────────────────────────────────────────────────────

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NotificationService] Notification tapée: ${response.id}, actionId: ${response.actionId}');
    _handleAction(response);
  }

  @pragma('vm:entry-point')
  static void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
    debugPrint('[NotificationService] Notification background tapée: ${response.id}, actionId: ${response.actionId}');
    _handleAction(response);
  }

  static void _handleAction(NotificationResponse response) {
    if (response.actionId == 'action_done') {
      debugPrint('[NotificationService] Action "✓ Fait / Pris" validée pour notification ${response.id}');
      // La notification est automatiquement acquittée et annulée
    } else if (response.actionId == 'action_snooze_10') {
      final snoozeDate = DateTime.now().add(const Duration(minutes: 10));
      final snoozeId = (response.id ?? 1000) + 70000;
      final payload = response.payload ?? 'Rappel personnel reporté';

      scheduleNotification(
        id: snoozeId,
        title: 'Rappel (Reporté 10 min)',
        body: payload,
        scheduledDate: snoozeDate,
        discretionLevel: 0,
        enableActions: true,
      );
      debugPrint('[NotificationService] Action "⏱ Rappeler dans 10 min" planifiée pour $snoozeDate');
    }
  }

  /// Convertit un [DateTime] en TZDateTime pour la planification en s'assurant
  /// que la date est strictement dans le futur (au moins +5 secondes).
  static tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final effectiveDateTime = dateTime.isBefore(now)
        ? now.add(const Duration(seconds: 10))
        : dateTime;

    return tz.TZDateTime(
      tz.local,
      effectiveDateTime.year,
      effectiveDateTime.month,
      effectiveDateTime.day,
      effectiveDateTime.hour,
      effectiveDateTime.minute,
      effectiveDateTime.second,
    );
  }
}
