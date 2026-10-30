import 'package:flutter_test/flutter_test.dart';
import 'package:intima/features/journal/domain/models/journal_category.dart';
import 'package:intima/features/journal/domain/models/journal_entry.dart';
import 'package:intima/features/journal/domain/models/journal_mood.dart';
import 'package:intima/features/journal/domain/models/journal_reminder.dart';
import 'package:intima/features/journal/domain/models/journal_stats.dart';

void main() {
  group('Journal Models & Stats Tests', () {
    test('JournalEntry JSON serialization and deserialization', () {
      final now = DateTime(2026, 10, 30, 14, 0);
      final entry = JournalEntry(
        id: 'test_entry_01',
        title: 'Pensée du jour',
        content: 'Un moment de calme et de sérénité.',
        date: now,
        createdAt: now,
        updatedAt: now,
        mood: JournalMoodType.peaceful,
        moodIntensity: 4,
        categoryId: 'cat_personal',
        tags: const ['Calme', 'Zen'],
        isFavorite: true,
        isDraft: false,
      );

      final json = entry.toJson();
      final restored = JournalEntry.fromJson(json);

      expect(restored.id, 'test_entry_01');
      expect(restored.title, 'Pensée du jour');
      expect(restored.content, 'Un moment de calme et de sérénité.');
      expect(restored.mood, JournalMoodType.peaceful);
      expect(restored.moodIntensity, 4);
      expect(restored.isFavorite, true);
      expect(restored.tags, contains('Calme'));
    });

    test('JournalStats calculation from entries', () {
      final now = DateTime.now();
      final entries = [
        JournalEntry(
          id: '1',
          content: 'Dix mots pour tester la métrique de mots du journal intime',
          date: now,
          createdAt: now,
          updatedAt: now,
          mood: JournalMoodType.happy,
          categoryId: 'cat_personal',
        ),
        JournalEntry(
          id: '2',
          content: 'Deuxième pensée rédigée hier avec gratitude et joie profonde',
          date: now.subtract(const Duration(days: 1)),
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
          mood: JournalMoodType.grateful,
          categoryId: 'cat_love',
        ),
      ];

      final stats = JournalStats.fromEntries(entries);

      expect(stats.totalEntries, 2);
      expect(stats.currentStreak, 2);
      expect(stats.moodDistribution[JournalMoodType.happy], 1);
      expect(stats.moodDistribution[JournalMoodType.grateful], 1);
      expect(stats.categoryCounts['cat_personal'], 1);
      expect(stats.categoryCounts['cat_love'], 1);
    });

    test('JournalCategory defaults and localized names', () {
      final defaults = JournalCategory.defaultCategories;
      expect(defaults.isNotEmpty, true);

      final personal = defaults.firstWhere((c) => c.id == 'cat_personal');
      expect(personal.localizedName('fr'), 'Vie personnelle');
      expect(personal.localizedName('en'), 'Personal Life');
    });

    test('JournalReminder model copyWith and parsing', () {
      final now = DateTime.now();
      final reminder = JournalReminder(
        id: 'rem_01',
        time: '21:30',
        repeatDays: const [1, 2, 3, 4, 5],
        message: 'Prends quelques minutes pour toi.',
        isActive: true,
        createdAt: now,
      );

      expect(reminder.hour, 21);
      expect(reminder.minute, 30);
      expect(reminder.repeatDays.length, 5);

      final modified = reminder.copyWith(isActive: false, time: '22:00');
      expect(modified.isActive, false);
      expect(modified.hour, 22);
      expect(modified.minute, 0);
    });
  });
}

