import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';
import '../errors/app_exceptions.dart';

/// Service de notifications locales pour INTIMA.
///
/// Toutes les notifications fonctionnent entièrement hors ligne.
/// Le contenu des notifications est contrôlé par le niveau de discrétion.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // ─── Initialisation ───────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Demande les permissions de notification à l'utilisateur.
  /// Retourne true si les permissions sont accordées.
  static Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool granted = false;

    if (android != null) {
      final result = await android.requestNotificationsPermission();
      granted = result ?? false;
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

  /// Planifie une notification locale.
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
  }) async {
    if (!_initialized) await initialize();

    final displayTitle = discretionLevel == 0
        ? AppConstants.appName
        : title;
    final displayBody = discretionLevel == 0
        ? 'Tu as un rappel personnel.'
        : body;

    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_notification',
      color: Color(0xFF88293E),
      showWhen: false,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        displayTitle,
        displayBody,
        _toTZDateTime(scheduledDate),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      throw NotificationException(
        'Impossible de planifier la notification.',
        cause: e,
      );
    }
  }

  /// Annule une notification planifiée par son identifiant.
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Affiche immédiatement une notification locale (idéal pour tester).
  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    int discretionLevel = 0,
  }) async {
    if (!_initialized) await initialize();

    final displayTitle = discretionLevel == 0 ? AppConstants.appName : title;
    final displayBody = discretionLevel == 0 ? 'Tu as un rappel personnel.' : body;

    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      color: Color(0xFF88293E),
      showWhen: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, displayTitle, displayBody, details);
  }

  /// Annule toutes les notifications planifiées.
  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Retourne la liste des notifications en attente.
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _plugin.pendingNotificationRequests();
  }

  // ─── Privé ────────────────────────────────────────────────────────────────────

  static void _onNotificationTapped(NotificationResponse response) {
    // Navigation gérée au niveau de l'application si nécessaire.
  }

  /// Convertit un [DateTime] en TZDateTime pour la planification.
  static tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }
}

