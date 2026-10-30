import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utilitaires de formatage de dates pour INTIMA.
/// Respecte la locale courante et les préférences de l'utilisateur.
class DateUtils {
  DateUtils._();

  /// Formate une date selon la locale et le format préféré.
  static String formatDate(DateTime date, {String locale = 'fr', String format = 'dd/MM/yyyy'}) {
    return DateFormat(format, locale).format(date);
  }

  /// Formate une date de manière lisible (ex. "29 octobre 2026").
  static String formatDateLong(DateTime date, {String locale = 'fr'}) {
    return DateFormat('d MMMM yyyy', locale).format(date);
  }

  /// Formate une date de manière courte (ex. "29 oct.").
  static String formatDateShort(DateTime date, {String locale = 'fr'}) {
    return DateFormat('d MMM', locale).format(date);
  }

  /// Formate une heure (ex. "14:30").
  static String formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Formate une date et heure complète.
  static String formatDateTime(DateTime dt, {String locale = 'fr'}) {
    return DateFormat('d MMM yyyy, HH:mm', locale).format(dt);
  }

  /// Retourne un label relatif (aujourd'hui, hier, il y a X jours).
  static String relativeLabel(DateTime date, {String locale = 'fr'}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;

    if (locale == 'fr') {
      if (diff == 0) return 'Aujourd\'hui';
      if (diff == 1) return 'Hier';
      if (diff < 7) return 'Il y a $diff jours';
      return formatDateShort(date, locale: locale);
    } else {
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      if (diff < 7) return '$diff days ago';
      return formatDateShort(date, locale: locale);
    }
  }

  /// Retourne le premier jour du mois.
  static DateTime firstDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  /// Retourne le dernier jour du mois.
  static DateTime lastDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0);

  /// Retourne le nombre de jours entre deux dates (valeur absolue).
  static int daysBetween(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return da.difference(db).inDays.abs();
  }

  /// Vérifie si deux dates tombent le même jour.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Retourne vrai si la date est aujourd'hui.
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Retourne le nom du mois localisé.
  static String monthName(int month, {String locale = 'fr'}) {
    final date = DateTime(2000, month);
    return DateFormat('MMMM', locale).format(date);
  }
}

