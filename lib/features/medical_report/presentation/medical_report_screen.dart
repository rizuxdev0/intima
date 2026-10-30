import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/intima_card.dart';
import '../../../shared/models/app_preferences.dart';
import '../../encounters/providers/encounters_provider.dart';
import '../../menstrual_cycle/providers/menstrual_cycle_provider.dart';
import '../../settings/providers/preferences_provider.dart';
import '../../sexual_health/data/sexual_health_repository.dart';
import '../../sexual_health/providers/sexual_health_provider.dart';
import '../../statistics/providers/correlation_provider.dart';
import '../domain/medical_report_pdf_builder.dart';
import '../domain/models/medical_report_config.dart';

/// Écran de génération et de personnalisation du rapport médical PDF.
class MedicalReportScreen extends ConsumerStatefulWidget {
  const MedicalReportScreen({super.key});

  @override
  ConsumerState<MedicalReportScreen> createState() => _MedicalReportScreenState();
}

class _MedicalReportScreenState extends ConsumerState<MedicalReportScreen> {
  MedicalReportConfig _config = const MedicalReportConfig();
  final TextEditingController _reasonController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _generateAndSharePdf() async {
    setState(() => _isGenerating = true);

    try {
      final prefs = ref.read(preferencesProvider).valueOrNull ?? const AppPreferences();
      final cycles = ref.read(menstrualCycleProvider).valueOrNull ?? [];
      final prediction = ref.read(cyclePredictionProvider);
      final sexualHealth = ref.read(sexualHealthProvider).valueOrNull ??
          const SexualHealthData();
      final encounters = ref.read(encountersProvider).valueOrNull ?? [];
      final correlationReport = ref.read(correlationReportProvider);

      final currentConfig = _config.copyWith(
        consultationReason: _reasonController.text.trim(),
      );

      final pdfBytes = await MedicalReportPdfBuilder.build(
        config: currentConfig,
        prefs: prefs,
        cycles: cycles,
        sexualHealth: sexualHealth,
        encounters: encounters,
        prediction: prediction,
        correlationReport: correlationReport,
      );

      // Sauvegarder dans le cache local
      final tempDir = await getTemporaryDirectory();
      final nowStr = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/Dossier_Medical_INTIMA_$nowStr.pdf');
      await file.writeAsBytes(pdfBytes, flush: true);

      if (mounted) {
        setState(() => _isGenerating = false);

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/pdf')],
          subject: 'Dossier Médical INTIMA - Consultation',
          text: 'Rapport médical et auto-suivi généré en toute confidentialité par INTIMA.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de génération : ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cycles = ref.watch(menstrualCycleProvider).valueOrNull ?? [];
    final sexualHealth = ref.watch(sexualHealthProvider).valueOrNull ?? const SexualHealthData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport Médical PDF'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Carte d'En-tête explicative
          IntimaCard(
            color: const Color(0xFF2D5A46).withValues(alpha: 0.08),
            borderColor: const Color(0xFF2D5A46).withValues(alpha: 0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.medical_services_outlined, color: Color(0xFF2D5A46), size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dossier pour votre consultation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A46),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Générez un document PDF synthétique et structuré pour votre gynécologue, médecin ou sage-femme.\n\nVos écrits personnels du journal et les noms de partenaires sont exclus par défaut pour préserver votre vie privée.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Période couverte
          _buildSectionHeader('PÉRIODE COUVERTE'),
          IntimaCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPeriodChoice(3, '3 mois'),
                _buildPeriodChoice(6, '6 mois (Recommandé)'),
                _buildPeriodChoice(12, '1 an'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Sections à inclure
          _buildSectionHeader('DONNÉES À INCLURE'),
          IntimaCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.water_drop_outlined, color: AppColors.calendarPeriod),
                  title: const Text('Cycles & Régularité'),
                  subtitle: Text('${cycles.length} cycles enregistrés'),
                  value: _config.includeCycles,
                  onChanged: (val) => setState(() => _config = _config.copyWith(includeCycles: val)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.healing_outlined, color: Color(0xFFFFB74D)),
                  title: const Text('Symptômes & Douleurs récurrentes'),
                  subtitle: const Text('Crampes, SPM, intensité moyenne'),
                  value: _config.includeSymptoms,
                  onChanged: (val) => setState(() => _config = _config.copyWith(includeSymptoms: val)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.health_and_safety_outlined, color: Color(0xFF2D5A46)),
                  title: const Text('Bilans IST & Vaccins'),
                  subtitle: Text('${sexualHealth.screenings.length} dépistage(s), ${sexualHealth.vaccinations.length} vaccin(s)'),
                  value: _config.includeSexualHealth,
                  onChanged: (val) => setState(() => _config = _config.copyWith(includeSexualHealth: val)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.person_off_outlined, color: Colors.blueGrey),
                  title: const Text('Anonymiser mon identité'),
                  subtitle: const Text('Masquer mon prénom sur le document imprimé'),
                  value: _config.anonymizePatientName,
                  onChanged: (val) => setState(() => _config = _config.copyWith(anonymizePatientName: val)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Motif de consultation
          _buildSectionHeader('MOTIF DE CONSULTATION (OPTIONNEL)'),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: 'Ex: Bilan annuel, contrôle frottis, règles douloureuses...',
              prefixIcon: const Icon(Icons.edit_note_rounded),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bouton d'action principal
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded),
              label: Text(
                _isGenerating ? 'Création du PDF en cours...' : 'Générer & Partager le PDF',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: _isGenerating ? null : _generateAndSharePdf,
            ),
          ),

          const SizedBox(height: 16),

          // Mention de sécurité
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Génération 100% locale. Aucun fichier n\'est téléversé en ligne.',
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPeriodChoice(int months, String label) {
    final isSelected = _config.dateRangeMonths == months;
    return InkWell(
      onTap: () => setState(() => _config = _config.copyWith(dateRangeMonths: months)),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
