import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/widgets/illustrations/intima_illustrations.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/app_preferences.dart';
import '../../../shared/models/encounter.dart';
import '../../encounters/providers/encounters_provider.dart';
import '../../journal/providers/journal_provider.dart';
import '../../journal/providers/journal_stats_provider.dart';
import '../../menstrual_cycle/providers/menstrual_cycle_provider.dart';
import '../../reminders/providers/reminders_provider.dart';
import '../../settings/providers/preferences_provider.dart';
import '../../sexual_health/providers/sexual_health_provider.dart';

/// Tableau de bord principal d'INTIMA.
/// Design aéré, élégant et moderne, respectant l'intimité et la clarté visuelle.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final prefsAsync = ref.watch(preferencesProvider);
    final encountersAsync = ref.watch(encountersProvider);
    final remindersAsync = ref.watch(remindersProvider);
    final prediction = ref.watch(cyclePredictionProvider);

    final prefs = prefsAsync.valueOrNull ?? const AppPreferences();
    final isDiscreet = prefs.discreetMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Recherche globale',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            tooltip: 'Mode discret',
            icon: Icon(
              isDiscreet ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: isDiscreet ? AppColors.accent : null,
            ),
            onPressed: () {
              ref
                  .read(preferencesProvider.notifier)
                  .setDiscreetMode(!isDiscreet);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(encountersProvider);
          ref.invalidate(remindersProvider);
          ref.invalidate(menstrualCycleProvider);
          ref.invalidate(journalEntriesProvider);
          ref.invalidate(sexualHealthProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            // 1. En-tête chaleureux et salutation aérée
            _buildGreetingHeader(context, theme, l10n, prefs),

            const SizedBox(height: 16),

            // 2. Barre Spotlight / Recherche globale moderne
            _buildSpotlightSearchPill(context, theme),

            const SizedBox(height: 20),

            // 3. Actions Rapides aérées et stylisées
            _buildQuickActionsSection(context, theme, l10n, prefs),

            const SizedBox(height: 24),

            // 4. Cartes Hero prioritaires selon le profil
            if (prefs.showCycleOnDashboard && prefs.hasMenstrualTracking) ...[
              _buildSectionHeader(
                context,
                title: 'Cycle & Fécondité',
                subtitle: 'Prévisions et observations corporelles',
              ),
              const SizedBox(height: 10),
              _buildModernCycleCard(context, theme, l10n, prediction, isDiscreet),
              const SizedBox(height: 20),
            ],

            if (prefs.showEncountersOnDashboard && prefs.hasRelationalTracking) ...[
              _buildSectionHeader(
                context,
                title: 'Vie Intime & Rencontres',
                subtitle: 'Moments partagés et statistiques relationnelles',
              ),
              const SizedBox(height: 10),
              _buildModernEncountersCard(
                context,
                theme,
                l10n,
                encountersAsync,
                isDiscreet,
              ),
              const SizedBox(height: 20),
            ],

            // 5. Section Bien-être & Journal Intime
            _buildSectionHeader(
              context,
              title: 'Pensées & Émotions',
              subtitle: 'Espace d\'écriture privé et suivi de l\'humeur',
            ),
            const SizedBox(height: 10),
            _buildModernJournalCard(context, theme, ref, isDiscreet),

            const SizedBox(height: 20),

            // 6. Section Santé & Prévention
            if (prefs.hasSexualHealthTracking) ...[
              _buildSectionHeader(
                context,
                title: 'Santé & Prévention',
                subtitle: 'Bilans IST, protection et traitements',
              ),
              const SizedBox(height: 10),
              _buildModernSexualHealthCard(context, theme, ref, isDiscreet),
              const SizedBox(height: 20),
            ],

            // 7. Section Rappels & Organisation
            if (prefs.showRemindersOnDashboard) ...[
              _buildSectionHeader(
                context,
                title: 'Rappels Personnels',
                subtitle: 'Notifications discrètes et sécurisées',
              ),
              const SizedBox(height: 10),
              _buildModernRemindersCard(
                context,
                theme,
                l10n,
                remindersAsync,
                isDiscreet,
              ),
              const SizedBox(height: 20),
            ],

            // 8. Fiches & Guides de Santé Pratique
            _buildSectionHeader(
              context,
              title: 'Guides & Savoirs',
              subtitle: 'Informations fiables 100% hors-ligne',
            ),
            const SizedBox(height: 10),
            _buildModernEducationCard(context, theme),
          ],
        ),
      ),
    );
  }

  // ─── En-tête Chaleureux ───────────────────────────────────────────────────

  Widget _buildGreetingHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    AppPreferences prefs,
  ) {
    final hour = DateTime.now().hour;
    final IconData timeIcon;
    final String greeting;

    if (hour < 12) {
      timeIcon = Icons.wb_sunny_rounded;
      greeting = l10n.dashboardGoodMorning;
    } else if (hour < 18) {
      timeIcon = Icons.wb_twilight_rounded;
      greeting = l10n.dashboardGoodAfternoon;
    } else {
      timeIcon = Icons.nights_stay_rounded;
      greeting = l10n.dashboardGoodEvening;
    }

    final hasName = prefs.userName.trim().isNotEmpty;
    final displayName = hasName ? prefs.userName.trim() : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(timeIcon, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayName != null ? '$greeting, $displayName' : greeting,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      du.DateUtils.formatDateLong(DateTime.now(), locale: prefs.locale),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.lock_rounded, size: 10, color: AppColors.sage),
                          SizedBox(width: 3),
                          Text(
                            'Privé',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.sage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Badge Héroïque vectoriel animé doux
          const AnimatedIntimaHeroBadge(size: 48),
        ],
      ),
    );
  }

  // ─── Barre Spotlight / Recherche ──────────────────────────────────────────

  Widget _buildSpotlightSearchPill(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => context.push(AppRoutes.search),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rechercher partenaires, journal, bilans...',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Spotlight',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Actions Rapides Aérées ───────────────────────────────────────────────

  Widget _buildQuickActionsSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    AppPreferences prefs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.dashboardQuickAdd,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              if (prefs.hasRelationalTracking) ...[
                _ModernQuickActionButton(
                  icon: Icons.favorite_rounded,
                  label: l10n.dashboardAddEncounter,
                  color: AppColors.accent,
                  onTap: () => context.push(AppRoutes.encounterNew),
                ),
                const SizedBox(width: 10),
                _ModernQuickActionButton(
                  icon: Icons.person_add_rounded,
                  label: l10n.dashboardAddPartner,
                  color: AppColors.primary,
                  onTap: () => context.push(AppRoutes.partnerNew),
                ),
                const SizedBox(width: 10),
              ],
              if (prefs.hasMenstrualTracking) ...[
                _ModernQuickActionButton(
                  icon: Icons.water_drop_rounded,
                  label: l10n.dashboardLogPeriod,
                  color: AppColors.calendarPeriod,
                  onTap: () => context.push(AppRoutes.cycleLog),
                ),
                const SizedBox(width: 10),
                _ModernQuickActionButton(
                  icon: Icons.healing_rounded,
                  label: l10n.dashboardLogSymptom,
                  color: AppColors.calendarSymptom,
                  onTap: () => context.push(AppRoutes.symptomForm),
                ),
                const SizedBox(width: 10),
              ],
              _ModernQuickActionButton(
                icon: Icons.edit_note_rounded,
                label: 'Journal',
                color: const Color(0xFF7E57C2),
                onTap: () => context.push(AppRoutes.journal),
              ),
              const SizedBox(width: 10),
              _ModernQuickActionButton(
                icon: Icons.alarm_add_rounded,
                label: l10n.dashboardAddReminder,
                color: AppColors.sage,
                onTap: () => context.push(AppRoutes.reminderNew),
              ),
              const SizedBox(width: 10),
              if (prefs.hasSexualHealthTracking) ...[
                _ModernQuickActionButton(
                  icon: Icons.health_and_safety_rounded,
                  label: 'Bilan IST',
                  color: const Color(0xFF2D5A46),
                  onTap: () => context.push(AppRoutes.sexualHealth),
                ),
                const SizedBox(width: 10),
              ],
              _ModernQuickActionButton(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Guides',
                color: const Color(0xFFE5A93C),
                onTap: () => context.push(AppRoutes.education),
              ),
              const SizedBox(width: 10),
              _ModernQuickActionButton(
                icon: Icons.picture_as_pdf_rounded,
                label: 'Rapport PDF',
                color: const Color(0xFFC0392B),
                onTap: () => context.push(AppRoutes.medicalReport),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── En-tête de Section ───────────────────────────────────────────────────

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Carte Cycle Menstruel Moderne ────────────────────────────────────────

  Widget _buildModernCycleCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic prediction,
    bool isDiscreet,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntimaCard(
        onTap: () => context.push(AppRoutes.cycleOverview),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCardIcon(
                  icon: Icons.water_drop_rounded,
                  color: AppColors.calendarPeriod,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDiscreet ? 'Suivi physiologique' : l10n.dashboardCycleTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prediction != null && prediction.isReliable
                            ? 'Moyenne : ${prediction.averageCycleDays.round()} jours de cycle'
                            : 'Données en cours de recueil',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            if (prediction == null || !prediction.isReliable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.calendarPeriod),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.cycleInsufficient,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.calendarPeriod.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.calendarPeriod.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.cycleNextEstimated,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            du.DateUtils.formatDateLong(
                              prediction.estimatedNextPeriodStart!,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.calendarPeriod,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (prediction.estimatedFertileWindowStart != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.calendarFertile.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.eco_rounded, size: 14, color: AppColors.calendarFertile),
                            SizedBox(width: 4),
                            Text(
                              'Fertilité',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.calendarFertile,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Carte Rencontres Intimes Moderne ──────────────────────────────────────

  Widget _buildModernEncountersCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    AsyncValue<List<Encounter>> encountersAsync,
    bool isDiscreet,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntimaCard(
        onTap: () => context.push(AppRoutes.encounters),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCardIcon(
                  icon: Icons.favorite_rounded,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDiscreet ? 'Activités partagées' : l10n.dashboardSummaryTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Historique intime confidentiel',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            encountersAsync.when(
              data: (encounters) {
                final total = encounters.length;
                final thisMonth = encounters.where((e) {
                  final now = DateTime.now();
                  return e.date.year == now.year && e.date.month == now.month;
                }).length;

                return Row(
                  children: [
                    // Bloc Total
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDiscreet ? 'Enregistrements' : 'Ce mois-ci',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$thisMonth',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Bloc Total Global
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total global',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$total',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Text(l10n.toastError),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Carte Journal Intime Moderne ─────────────────────────────────────────

  Widget _buildModernJournalCard(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    bool isDiscreet,
  ) {
    final entriesAsync = ref.watch(journalEntriesProvider);
    final stats = ref.watch(journalStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntimaCard(
        onTap: () => context.push(AppRoutes.journal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCardIcon(
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF7E57C2),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Journal Intime & Humeur',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vos réflexions et humeurs en toute sécurité',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (stats.currentStreak > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '🔥 ${stats.currentStreak} j',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 14),
            entriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7E57C2).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_note_rounded, color: Color(0xFF7E57C2), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Comment vous sentez-vous aujourd\'hui ? Touchez pour écrire.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final latest = entries.first;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(latest.mood.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDiscreet ? 'Dernier écrit confidentiel' : latest.displayTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              du.DateUtils.formatDate(latest.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Journal disponible'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Carte Santé Sexuelle & Prévention Moderne ────────────────────────────

  Widget _buildModernSexualHealthCard(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    bool isDiscreet,
  ) {
    final daysSinceLastScreening = ref.watch(daysSinceLastScreeningProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntimaCard(
        onTap: () => context.push(AppRoutes.sexualHealth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCardIcon(
                  icon: Icons.health_and_safety_rounded,
                  color: const Color(0xFF2D5A46),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Santé Sexuelle & Bilans IST',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Protection, dépistages et vaccinations',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5A46).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF2D5A46).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    daysSinceLastScreening != null && daysSinceLastScreening < 180
                        ? Icons.verified_user_rounded
                        : Icons.info_outline_rounded,
                    color: daysSinceLastScreening != null && daysSinceLastScreening < 180
                        ? const Color(0xFF2D5A46)
                        : AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isDiscreet
                          ? 'Statut de protection confidentiel'
                          : (daysSinceLastScreening != null
                              ? 'Dernier bilan il y a $daysSinceLastScreening jours (Négatif)'
                              : 'Aucun test enregistré. Planifier un contrôle préventif.'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Carte Rappels Personnels Moderne ─────────────────────────────────────

  Widget _buildModernRemindersCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    AsyncValue<dynamic> remindersAsync,
    bool isDiscreet,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntimaCard(
        onTap: () => context.push(AppRoutes.reminders),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCardIcon(
                  icon: Icons.alarm_rounded,
                  color: AppColors.sage,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardNextReminder,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Alertes locales et discrètes',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 14),
            remindersAsync.when(
              data: (reminders) {
                if (reminders.isEmpty) {
                  return Text(
                    l10n.dashboardNoReminders,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  );
                }
                final next = reminders.first;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, size: 18, color: AppColors.sage),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isDiscreet ? 'Rappel personnel discret' : next.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (next.scheduledTime != null)
                        Text(
                          next.scheduledTime!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.sage,
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Text(l10n.toastError),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Carte Guides & Savoirs Moderne ───────────────────────────────────────

  Widget _buildModernEducationCard(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IntimaCard(
        onTap: () => context.push(AppRoutes.education),
        child: Row(
          children: [
            _buildCardIcon(
              icon: Icons.lightbulb_outline_rounded,
              color: const Color(0xFFE5A93C),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fiches Pratiques & Guides Bien-être',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '8 fiches rédigées : cycle, consentement, dépistages IST...',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ─── Utilitaire Icône Ronde Douce ─────────────────────────────────────────

  Widget _buildCardIcon({required IconData icon, required Color color}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ─── Bouton d'Action Rapide Moderne & Aéré ──────────────────────────────────

class _ModernQuickActionButton extends StatelessWidget {
  const _ModernQuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.22),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
