import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/constants/app_constants.dart';

void main() {
  group('Notification Constants & Discretion Tests', () {
    test('Notification Channel & IDs sont valides', () {
      expect(AppConstants.notificationChannelId, isNotEmpty);
      expect(AppConstants.notificationChannelName, isNotEmpty);
      expect(AppConstants.testNotificationId, 9999);
      expect(AppConstants.pillNotificationId, 8801);
      expect(AppConstants.checkinNotificationId, 8802);
      expect(AppConstants.periodNotificationId, 8803);
    });

    test('Logique de discrétion niveau 0, 1 et 2', () {
      const originalTitle = 'Prendre pilule contraceptive';
      const originalBody = 'Dose quotidienne à heure fixe.';

      String resolveTitle(int discretionLevel) =>
          discretionLevel == 0 ? AppConstants.appName : originalTitle;

      String resolveBody(int discretionLevel) =>
          discretionLevel == 0 ? 'Tu as un rappel personnel.' : originalBody;

      // Niveau 0 : Discret (100% anonyme)
      expect(resolveTitle(0), AppConstants.appName);
      expect(resolveBody(0), 'Tu as un rappel personnel.');

      // Niveau 1 & 2 : Titre visible
      expect(resolveTitle(1), originalTitle);
      expect(resolveBody(1), originalBody);
    });
  });
}

