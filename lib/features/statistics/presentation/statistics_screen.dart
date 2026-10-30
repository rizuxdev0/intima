import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/app_preferences.dart';
import '../../encounters/providers/encounters_provider.dart';
import '../../menstrual_cycle/providers/menstrual_cycle_provider.dart';
import '../../partners/providers/partners_provider.dart';
import '../../settings/providers/preferences_provider.dart';
import '../providers/correlation_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(preferencesProvider).valueOrNull ?? const AppPreferences();
    final hasCycle = prefs.hasMenstrualTracking;

    if (!hasCycle) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.statsTitle),
        ),
        body: _buildRelationalStats(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.statsRelational),
            Tab(text: l10n.statsMenstrual),
            const Tab(text: 'Corrélations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRelationalStats(context),
          _buildMenstrualStats(context),
          _buildCorrelationStats(context),
        ],
      ),
    );
  }

  Widget _buildRelationalStats(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final encounters = ref.watch(encountersProvider).valueOrNull ?? [];
    final partners = ref.watch(partnersProvider).valueOrNull ?? [];

    if (encounters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.toastNoData,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Regrouper par partenaire
    final partnerCounts = <String, int>{};
    for (final e in encounters) {
      final pid = e.partnerId ?? 'unknown';
      partnerCounts[pid] = (partnerCounts[pid] ?? 0) + 1;
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Total des rencontres
        IntimaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.statsEncountersTotal,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                '${encounters.length}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Répartition par partenaire
        if (partners.isNotEmpty)
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.statsByPartner,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                ...partners.map((partner) {
                  final count = partnerCounts[partner.id] ?? 0;
                  final percentage = encounters.isNotEmpty
                      ? (count / encounters.length * 100).round()
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              partner.displayName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text('$count ($percentage %)'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: encounters.isNotEmpty
                                ? count / encounters.length
                                : 0,
                            backgroundColor: Colors.grey.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation(Color(partner.color)),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMenstrualStats(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cycles = ref.watch(menstrualCycleProvider).valueOrNull ?? [];
    final prediction = ref.watch(cyclePredictionProvider);

    if (cycles.length < 2 || prediction == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.analytics_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n.statsNoDataSufficient,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Durée moyenne du cycle
        IntimaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.statsAvgCycleDuration,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                '${prediction.averageCycleDays.round()} jours',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.calendarPeriod,
                ),
              ),
            ],
          ),
        ),

        // Durée moyenne des règles
        if (prediction.averagePeriodDays != null) ...[
          const SizedBox(height: 8),
          IntimaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.statsAvgPeriodDuration,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  '${prediction.averagePeriodDays!.round()} jours',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Variabilité des cycles
        const SizedBox(height: 8),
        IntimaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.statsVariability,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                '± ${prediction.cycleVariabilityDays.toStringAsFixed(1)} jours',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                prediction.cycleVariabilityDays <= 3.0
                    ? 'Cycles réguliers'
                    : 'Cycles variables',
                style: TextStyle(
                  fontSize: 13,
                  color: prediction.cycleVariabilityDays <= 3.0
                      ? AppColors.success
                      : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Explication de la méthode de calcul
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${l10n.statsMethodExplanation} : Les moyennes sont calculées à partir des dates de début déclarées, par différence arithmétique. L\'écart-type mesure la régularité.',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationStats(BuildContext context) {
    final report = ref.watch(correlationReportProvider);
    final theme = Theme.of(context);

    if (!report.hasSufficientData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: IntimaCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7E57C2).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 40,
                    color: Color(0xFF7E57C2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Découvrez vos corrélations intimes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'INTIMA croise automatiquement vos phases hormonales (menstruation, ovulation, lutéale) avec vos ressentis notés dans le journal intime et vos rencontres.\n\nNotez au moins 3 écrits dans votre journal pour faire émerger vos premières tendances.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        // Carte d'En-tête : Équilibre & Synthèse
        IntimaCard(
          color: const Color(0xFF7E57C2).withValues(alpha: 0.08),
          borderColor: const Color(0xFF7E57C2).withValues(alpha: 0.25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Color(0xFF7E57C2), size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Harmonie Émotionnelle & Cycle',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF7E57C2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Analyse algorithmique croisée de ${report.totalJournalEntries} écrits du journal intime et ${report.totalCycles} cycles.',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 16),
              // Badges des phases clés
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (report.peakEnergyPhase != null)
                    _buildCorrelationBadge(
                      label: 'Pic d\'énergie',
                      value: '${report.peakEnergyPhase!.emoji} ${report.peakEnergyPhase!.shortName}',
                      color: const Color(0xFF4DB6AC),
                    ),
                  if (report.mostReflectivePhase != null)
                    _buildCorrelationBadge(
                      label: 'Sensibilité / Repos',
                      value: '${report.mostReflectivePhase!.emoji} ${report.mostReflectivePhase!.shortName}',
                      color: const Color(0xFFFFB74D),
                    ),
                  if (report.peakIntimacyPhase != null)
                    _buildCorrelationBadge(
                      label: 'Épanouissement intime',
                      value: '${report.peakIntimacyPhase!.emoji} ${report.peakIntimacyPhase!.shortName}',
                      color: const Color(0xFFD84A75),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Humeurs & Bien-être selon la Phase',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Liste des 4 phases
        ...report.phaseSummaries.map((summary) {
          final phase = summary.phase;
          final hasEntries = summary.entryCount > 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntimaCard(
              borderColor: phase.color.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: phase.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(phase.emoji, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              phase.labelFr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              phase.daysRangeText,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: phase.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          hasEntries ? '${summary.entryCount} écrit${summary.entryCount > 1 ? 's' : ''}' : 'Aucun écrit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: phase.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    phase.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  if (hasEntries) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (summary.dominantMood != null) ...[
                          Text(
                            'Émotion dominante : ${summary.dominantMood!.emoji} ${summary.dominantMood!.labelFr}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],
                        Text(
                          '${summary.positivePercentage.round()}% positif',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: summary.positivePercentage >= 50
                                ? AppColors.success
                                : AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: summary.positivePercentage / 100.0,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          summary.positivePercentage >= 50 ? AppColors.success : AppColors.accent,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    if (summary.encountersCount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFD84A75)),
                          const SizedBox(width: 6),
                          Text(
                            '${summary.encountersCount} rencontre${summary.encountersCount > 1 ? 's' : ''} intime${summary.encountersCount > 1 ? 's' : ''} enregistrée${summary.encountersCount > 1 ? 's' : ''} pendant cette phase.',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 14),

        // Section Insights Découverts
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Observations & Conseils Clés',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 10),

        ...report.insights.map((insight) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IntimaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: insight.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(insight.icon, color: insight.accentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              insight.category,
                              style: TextStyle(
                                fontSize: 11,
                                color: insight.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (insight.badgeText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: insight.accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            insight.badgeText!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: insight.accentColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    insight.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Note de confidentialité
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ces corrélations sont générées 100% hors ligne sur votre appareil. Zéro cloud, zéro télémétrie.',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
