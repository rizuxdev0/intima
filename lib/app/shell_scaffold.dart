import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/settings/providers/preferences_provider.dart';
import '../shared/models/app_preferences.dart';
import 'localization/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({
    super.key,
    required this.shell,
  });

  final StatefulNavigationShell shell;

  void _showQuickActionsModal(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(preferencesProvider).valueOrNull ?? const AppPreferences();
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée de glissement
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // En-tête
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ajout & Actions Rapides',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Raccourci vers la recherche globale
              InkWell(
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push(AppRoutes.search);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Recherche globale instantanée...',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Spotlight',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grille d'actions rapides
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickActionTile(
                    title: 'Rencontre',
                    subtitle: 'Noter un moment intime',
                    icon: Icons.favorite_rounded,
                    color: AppColors.accent,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push(AppRoutes.encounterNew);
                    },
                  ),
                  _QuickActionTile(
                    title: 'Journal',
                    subtitle: 'Écrire une pensée secrète',
                    icon: Icons.edit_note_rounded,
                    color: const Color(0xFF7E57C2),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push(AppRoutes.journalNew);
                    },
                  ),
                  _QuickActionTile(
                    title: 'Partenaire',
                    subtitle: 'Ajouter une relation',
                    icon: Icons.person_add_rounded,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push(AppRoutes.partnerNew);
                    },
                  ),
                  _QuickActionTile(
                    title: 'Santé IST',
                    subtitle: 'Enregistrer un dépistage',
                    icon: Icons.health_and_safety_rounded,
                    color: const Color(0xFF2D5A46),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push(AppRoutes.sexualHealthScreeningNew);
                    },
                  ),
                  _QuickActionTile(
                    title: 'Rappel',
                    subtitle: 'PrEP, pilule, rendez-vous',
                    icon: Icons.alarm_add_rounded,
                    color: AppColors.sage,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push(AppRoutes.reminderNew);
                    },
                  ),
                  if (prefs.hasMenstrualTracking)
                    _QuickActionTile(
                      title: 'Règles & Cycle',
                      subtitle: 'Noter flux et symptômes',
                      icon: Icons.water_drop_rounded,
                      color: AppColors.calendarPeriod,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        context.push(AppRoutes.cycleLog);
                      },
                    ),
                  _QuickActionTile(
                    title: 'Rapport PDF',
                    subtitle: 'Exporter dossier soignant',
                    icon: Icons.picture_as_pdf_rounded,
                    color: const Color(0xFFD32F2F),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.push(AppRoutes.medicalReport);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: shell,
      floatingActionButton: FloatingActionButton(
        heroTag: 'shell_global_quick_action_fab',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tooltip: 'Actions rapides',
        onPressed: () => _showQuickActionsModal(context, ref),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) {
          shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: l10n.navPartners,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_graph_outlined),
            selectedIcon: const Icon(Icons.auto_graph_rounded),
            label: l10n.navInsights,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_rounded),
            selectedIcon: const Icon(Icons.menu_rounded),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = (MediaQuery.of(context).size.width - 52) / 2;

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
