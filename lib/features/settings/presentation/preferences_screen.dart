import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/app_preferences.dart';
import '../providers/preferences_provider.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  String _getGenderLabel(UserGender gender) {
    switch (gender) {
      case UserGender.female:
        return 'Femme';
      case UserGender.male:
        return 'Homme';
      case UserGender.nonBinary:
        return 'Non-binaire / Autre';
      case UserGender.notSpecified:
        return 'Non précisé';
    }
  }

  String _getUsageModeLabel(UsageMode mode) {
    switch (mode) {
      case UsageMode.relationships:
        return 'Intimité & Relations (sans cycle)';
      case UsageMode.full:
        return 'Suivi Complet (Cycle + Intimité)';
      case UsageMode.personal:
        return 'Journal & Bien-être personnel';
      case UsageMode.menstrual:
        return 'Cycle menstruel seul';
    }
  }

  Future<void> _editUsageMode(BuildContext context, WidgetRef ref, UsageMode current) async {
    final selected = await showDialog<UsageMode>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Mode d\'utilisation'),
        children: UsageMode.values.map((m) {
          return SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(m),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    m == current ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: m == current ? AppColors.primary : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_getUsageModeLabel(m))),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      final notifier = ref.read(preferencesProvider.notifier);
      await notifier.setUsageMode(selected);
      await notifier.setDashboardCardVisibility(
        showCycle: selected == UsageMode.full || selected == UsageMode.menstrual,
        showEncounters: selected == UsageMode.full || selected == UsageMode.relationships,
      );
    }
  }

  Future<void> _editUserName(BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier votre prénom / pseudo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Votre prénom ou pseudo (facultatif)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (newName != null) {
      await ref.read(preferencesProvider.notifier).setUserName(newName);
    }
  }

  Future<void> _editUserGender(BuildContext context, WidgetRef ref, UserGender current) async {
    final selected = await showDialog<UserGender>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Sélectionnez votre profil'),
        children: UserGender.values.map((g) {
          return SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(g),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    g == current ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: g == current ? AppColors.primary : null,
                  ),
                  const SizedBox(width: 12),
                  Text(_getGenderLabel(g)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      await ref.read(preferencesProvider.notifier).setUserGender(selected);
    }
  }

  Future<void> _editBirthYear(BuildContext context, WidgetRef ref, int? currentYear) async {
    final current = DateTime.now().year;
    final yearsList = List.generate(70, (index) => current - 13 - index);
    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Sélectionnez votre année de naissance'),
        children: yearsList.map((y) {
          return SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(y),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                '$y',
                style: TextStyle(
                  fontWeight: y == currentYear ? FontWeight.bold : FontWeight.normal,
                  color: y == currentYear ? AppColors.primary : null,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
    if (selected != null) {
      await ref.read(preferencesProvider.notifier).setBirthYear(selected);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(preferencesProvider).valueOrNull ?? const AppPreferences();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingPreferencesTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Profil & Identité
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profil & Identité',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                  title: const Text('Prénom ou pseudonyme'),
                  subtitle: Text(
                    prefs.userName.isNotEmpty
                        ? prefs.userName
                        : 'Non renseigné (facultatif)',
                  ),
                  trailing: const Icon(Icons.edit_outlined, size: 20),
                  onTap: () => _editUserName(context, ref, prefs.userName),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.transgender_rounded, color: AppColors.primary),
                  title: const Text('Genre déclaré'),
                  subtitle: Text(_getGenderLabel(prefs.userGender)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _editUserGender(context, ref, prefs.userGender),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                  title: const Text('Année de naissance'),
                  subtitle: Text(
                    prefs.birthYear != null
                        ? '${prefs.birthYear}'
                        : 'Non renseignée (facultatif)',
                  ),
                  trailing: const Icon(Icons.edit_outlined, size: 20),
                  onTap: () => _editBirthYear(context, ref, prefs.birthYear),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.tune_rounded, color: AppColors.primary),
                  title: const Text('Mode d\'utilisation'),
                  subtitle: Text(_getUsageModeLabel(prefs.usageMode)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _editUsageMode(context, ref, prefs.usageMode),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          // Langue
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguage,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: prefs.locale,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(preferencesProvider.notifier).setLocale(val);
                    }
                  },
                  child: Column(
                    children: const [
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Français'),
                        value: 'fr',
                      ),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: Text('English'),
                        value: 'en',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Thème
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsTheme,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                RadioGroup<ThemeMode>(
                  groupValue: prefs.themeMode,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(preferencesProvider.notifier).setThemeMode(val);
                    }
                  },
                  child: Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsThemeSystem),
                        value: ThemeMode.system,
                      ),
                      RadioListTile<ThemeMode>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsThemeLight),
                        value: ThemeMode.light,
                      ),
                      RadioListTile<ThemeMode>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsThemeDark),
                        value: ThemeMode.dark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Calendrier
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsWeekStart,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsWeekStartMonday),
                  value: prefs.weekStartsOnMonday,
                  onChanged: (val) {
                    ref.read(preferencesProvider.notifier).setWeekStartsOnMonday(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Cartes du tableau de bord
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cartes du tableau de bord',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Résumé des rencontres'),
                  value: prefs.showEncountersOnDashboard,
                  onChanged: (val) {
                    ref
                        .read(preferencesProvider.notifier)
                        .setDashboardCardVisibility(showEncounters: val);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Résumé du cycle'),
                  value: prefs.showCycleOnDashboard,
                  onChanged: (val) {
                    ref
                        .read(preferencesProvider.notifier)
                        .setDashboardCardVisibility(showCycle: val);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Prochains rappels'),
                  value: prefs.showRemindersOnDashboard,
                  onChanged: (val) {
                    ref
                        .read(preferencesProvider.notifier)
                        .setDashboardCardVisibility(showReminders: val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

