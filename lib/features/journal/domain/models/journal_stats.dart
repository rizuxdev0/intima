import 'journal_entry.dart';
import 'journal_mood.dart';

/// Statistiques et métriques d'écriture du Journal Intime.
class JournalStats {
  const JournalStats({
    required this.totalEntries,
    required this.entriesThisMonth,
    required this.currentStreak,
    required this.longestStreak,
    required this.moodDistribution,
    required this.categoryCounts,
    required this.totalWordsWritten,
    required this.recentMoods,
  });

  final int totalEntries;
  final int entriesThisMonth;
  final int currentStreak; // Jours consécutifs d'écriture actuels
  final int longestStreak;
  final Map<JournalMoodType, int> moodDistribution;
  final Map<String, int> categoryCounts;
  final int totalWordsWritten;
  final List<JournalMoodPoint> recentMoods;

  factory JournalStats.fromEntries(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return const JournalStats(
        totalEntries: 0,
        entriesThisMonth: 0,
        currentStreak: 0,
        longestStreak: 0,
        moodDistribution: {},
        categoryCounts: {},
        totalWordsWritten: 0,
        recentMoods: [],
      );
    }

    // Filtre les brouillons
    final validEntries = entries.where((e) => !e.isDraft).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final now = DateTime.now();
    int thisMonth = 0;
    int totalWords = 0;
    final Map<JournalMoodType, int> moods = {};
    final Map<String, int> categories = {};
    final List<JournalMoodPoint> moodPoints = [];

    final Set<String> uniqueDays = {};

    for (final e in validEntries) {
      if (e.date.year == now.year && e.date.month == now.month) {
        thisMonth++;
      }
      final words = e.content.trim().split(RegExp(r'\s+')).length;
      totalWords += words;

      moods[e.mood] = (moods[e.mood] ?? 0) + 1;
      categories[e.categoryId] = (categories[e.categoryId] ?? 0) + 1;

      final dayKey = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      uniqueDays.add(dayKey);

      if (moodPoints.length < 14) {
        moodPoints.add(JournalMoodPoint(
          date: e.date,
          mood: e.mood,
          intensity: e.moodIntensity,
        ));
      }
    }

    // Calcul des séries consécutives (streak)
    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    final todayKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
    final yesterday = checkDate.subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    // Si pas écrit aujourd'hui, vérifier si la série continue depuis hier
    if (!uniqueDays.contains(todayKey) && uniqueDays.contains(yesterdayKey)) {
      checkDate = yesterday;
    }

    while (true) {
      final key = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if (uniqueDays.contains(key)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return JournalStats(
      totalEntries: validEntries.length,
      entriesThisMonth: thisMonth,
      currentStreak: streak,
      longestStreak: streak > 0 ? streak : 0,
      moodDistribution: moods,
      categoryCounts: categories,
      totalWordsWritten: totalWords,
      recentMoods: moodPoints.reversed.toList(),
    );
  }
}

class JournalMoodPoint {
  const JournalMoodPoint({
    required this.date,
    required this.mood,
    required this.intensity,
  });

  final DateTime date;
  final JournalMoodType mood;
  final int intensity;
}

