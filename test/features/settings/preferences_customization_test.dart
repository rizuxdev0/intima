import 'package:flutter_test/flutter_test.dart';
import 'package:intima/shared/models/app_preferences.dart';

void main() {
  group('AppPreferences Customization & Gender Tracking Tests', () {
    test('Un profil masculin ou en mode relationnel désactive tout suivi menstruel', () {
      const maleRelationalPrefs = AppPreferences(
        userGender: UserGender.male,
        usageMode: UsageMode.relationships,
        goals: ['intimacy', 'health', 'journal'],
      );

      expect(maleRelationalPrefs.hasMenstrualTracking, isFalse);
      expect(maleRelationalPrefs.hasRelationalTracking, isTrue);
      expect(maleRelationalPrefs.hasJournalTracking, isTrue);
      expect(maleRelationalPrefs.hasSexualHealthTracking, isTrue);
    });

    test('Un profil complet conserve le suivi menstruel et relationnel', () {
      const fullPrefs = AppPreferences(
        userGender: UserGender.female,
        usageMode: UsageMode.full,
        goals: ['cycle', 'intimacy', 'symptoms', 'journal'],
      );

      expect(fullPrefs.hasMenstrualTracking, isTrue);
      expect(fullPrefs.hasRelationalTracking, isTrue);
      expect(fullPrefs.hasJournalTracking, isTrue);
    });

    test('Un profil cycle pur désactive le relationnel', () {
      const cycleOnlyPrefs = AppPreferences(
        usageMode: UsageMode.menstrual,
        goals: ['cycle', 'symptoms'],
      );

      expect(cycleOnlyPrefs.hasMenstrualTracking, isTrue);
      expect(cycleOnlyPrefs.hasRelationalTracking, isFalse);
    });

    test('Un profil journal personnel pur désactive cycle et relationnel', () {
      const journalOnlyPrefs = AppPreferences(
        usageMode: UsageMode.personal,
        goals: ['journal'],
      );

      expect(journalOnlyPrefs.hasMenstrualTracking, isFalse);
      expect(journalOnlyPrefs.hasRelationalTracking, isFalse);
      expect(journalOnlyPrefs.hasJournalTracking, isTrue);
    });
  });
}

