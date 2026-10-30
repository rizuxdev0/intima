import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/intima_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Avertissement médical
          IntimaCard(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderColor: AppColors.warning.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      l10n.helpDisclaimerTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.helpDisclaimerBody,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 1. Phases du cycle
          _buildEducationalCard(
            context,
            Icons.water_drop_outlined,
            l10n.helpCyclePhases,
            l10n.helpCyclePhasesBody,
          ),

          // 2. Différence entre règles et ovulation
          _buildEducationalCard(
            context,
            Icons.compare_arrows_rounded,
            l10n.helpPeriodVsOvulationTitle,
            l10n.helpPeriodVsOvulationBody,
          ),

          // 3. Fertilité & Variations
          _buildEducationalCard(
            context,
            Icons.eco_outlined,
            l10n.helpFertility,
            l10n.helpFertilityBody,
          ),

          // 4. Pourquoi la durée varie
          _buildEducationalCard(
            context,
            Icons.timeline_rounded,
            l10n.helpCycleVariationsTitle,
            l10n.helpCycleVariationsBody,
          ),

          // 5. Limites des prédictions
          _buildEducationalCard(
            context,
            Icons.help_outline_rounded,
            l10n.helpPredictionLimitsTitle,
            l10n.helpPredictionLimitsBody,
          ),

          // 6. Contraception
          _buildEducationalCard(
            context,
            Icons.shield_outlined,
            l10n.helpContraception,
            l10n.helpContraceptionBody,
          ),

          // 7. Prévention des IST
          _buildEducationalCard(
            context,
            Icons.health_and_safety_outlined,
            l10n.helpSTI,
            l10n.helpSTIBody,
          ),

          // 8. Quand consulter un médecin
          _buildEducationalCard(
            context,
            Icons.medical_services_outlined,
            l10n.helpWhenToSeeDoctor,
            l10n.helpWhenToSeeDoctorBody,
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalCard(
    BuildContext context,
    IconData icon,
    String title,
    String content,
  ) {
    return IntimaCard(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

