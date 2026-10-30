import 'package:flutter_test/flutter_test.dart';
import 'package:intima/shared/models/app_preferences.dart';
import 'package:intima/shared/models/encounter.dart';
import 'package:intima/shared/models/menstrual_cycle.dart';
import 'package:intima/shared/models/partner.dart';
import 'package:intima/shared/models/reminder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Demo data models serialization and deserialization integrity', () {
    const prefs = AppPreferences(
      userName: 'Alex',
      userGender: UserGender.female,
      birthYear: 1998,
      goals: ['cycle', 'intimacy', 'symptoms'],
      referralSource: 'store',
      acceptedPrivacyPolicy: true,
      onboardingCompleted: true,
    );

    final json = prefs.toJson();
    final restored = AppPreferences.fromJson(json);

    expect(restored.userName, equals('Alex'));
    expect(restored.userGender, equals(UserGender.female));
    expect(restored.birthYear, equals(1998));
    expect(restored.goals, contains('cycle'));
    expect(restored.acceptedPrivacyPolicy, isTrue);

    // Test Partner
    final partner = Partner(
      id: 'p1',
      createdAt: DateTime(2024, 1, 1),
      name: 'Lucas',
      color: 0xFF88293E,
      tags: const ['Régulier'],
    );
    expect(Partner.fromJson(partner.toJson()).name, equals('Lucas'));

    // Test Encounter
    final encounter = Encounter(
      id: 'e1',
      date: DateTime(2024, 5, 1),
      createdAt: DateTime(2024, 5, 1),
      partnerId: 'p1',
      type: EncounterType.intimate,
      protectionUsed: ProtectionType.condom,
    );
    expect(Encounter.fromJson(encounter.toJson()).partnerId, equals('p1'));

    // Test Menstrual Cycle
    final cycle = MenstrualCycle(
      id: 'c1',
      startDate: DateTime(2024, 5, 1),
      createdAt: DateTime(2024, 5, 1),
      flowIntensity: 1,
      symptoms: [
        CycleSymptom(date: DateTime(2024, 5, 1), type: SymptomType.cramps, intensity: 3),
      ],
    );
    expect(MenstrualCycle.fromJson(cycle.toJson()).symptoms.length, equals(1));

    // Test Reminder
    final reminder = Reminder(
      id: 'r1',
      title: 'Pilule',
      scheduledDate: DateTime(2024, 5, 1),
      createdAt: DateTime(2024, 5, 1),
      category: ReminderCategory.medical,
    );
    expect(Reminder.fromJson(reminder.toJson()).title, equals('Pilule'));
  });
}
