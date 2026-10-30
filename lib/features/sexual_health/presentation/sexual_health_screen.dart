import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/illustrations/intima_illustrations.dart';
import '../../../core/widgets/intima_card.dart';
import '../domain/models/prep_record.dart';
import '../domain/models/sti_screening.dart';
import '../providers/sexual_health_provider.dart';

/// Écran principal du Module Santé Sexuelle & Prévention.
class SexualHealthScreen extends ConsumerStatefulWidget {
  const SexualHealthScreen({super.key});

  @override
  ConsumerState<SexualHealthScreen> createState() => _SexualHealthScreenState();
}

class _SexualHealthScreenState extends ConsumerState<SexualHealthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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

  void _showPrepModal(BuildContext context, PrepRecord currentPrep) {
    PrepRegimen regimen = currentPrep.regimen;
    DateTime? nextKidney = currentPrep.nextKidneyCheckDate;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final theme = Theme.of(ctx);
          final locale = Localizations.localeOf(ctx).languageCode;
          final dateFormat = DateFormat('dd/MM/yyyy', locale);

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Suivi PrEP (VIH)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Protocole PrEP', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<PrepRegimen>(
                  initialValue: regimen,
                  isExpanded: true,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
                  items: PrepRegimen.values
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.labelFr, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => regimen = val);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.biotech_rounded, color: AppColors.accent),
                  title: const Text('Prochain bilan rénal (Créatinine)'),
                  subtitle: Text(nextKidney != null ? dateFormat.format(nextKidney!) : 'Non programmé'),
                  trailing: OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: nextKidney ?? DateTime.now().add(const Duration(days: 90)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setModalState(() => nextKidney = picked);
                    },
                    child: const Text('Définir'),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final updated = currentPrep.copyWith(
                        regimen: regimen,
                        nextKidneyCheckDate: nextKidney,
                      );
                      await ref.read(sexualHealthProvider.notifier).savePrep(updated);
                      if (context.mounted) Navigator.of(ctx).pop();
                    },
                    child: const Text('Enregistrer le protocole'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('d MMMM yyyy', locale);

    final dataAsync = ref.watch(sexualHealthProvider);
    final data = dataAsync.valueOrNull;
    final screenings = data?.screenings ?? [];
    final vaccinations = data?.vaccinations ?? [];
    final prep = data?.prep ?? const PrepRecord();
    final daysSinceLastScreening = ref.watch(daysSinceLastScreeningProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5A46).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF2D5A46), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Santé & Dépistages',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Dépistages IST'),
            Tab(text: 'Vaccins'),
            Tab(text: 'PrEP & Prévention'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Carte Statut Global
          Padding(
            padding: const EdgeInsets.all(16),
            child: IntimaCard(
              color: daysSinceLastScreening != null && daysSinceLastScreening < 180
                  ? const Color(0xFF2D5A46).withValues(alpha: isDark ? 0.2 : 0.08)
                  : AppColors.accent.withValues(alpha: isDark ? 0.2 : 0.08),
              borderColor: daysSinceLastScreening != null && daysSinceLastScreening < 180
                  ? const Color(0xFF2D5A46).withValues(alpha: 0.3)
                  : AppColors.accent.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: daysSinceLastScreening != null && daysSinceLastScreening < 180
                          ? const Color(0xFF2D5A46).withValues(alpha: 0.2)
                          : AppColors.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      daysSinceLastScreening != null && daysSinceLastScreening < 180
                          ? Icons.verified_user_rounded
                          : Icons.access_time_rounded,
                      color: daysSinceLastScreening != null && daysSinceLastScreening < 180
                          ? const Color(0xFF2D5A46)
                          : AppColors.accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          daysSinceLastScreening != null
                              ? 'Dernier bilan il y a $daysSinceLastScreening jours'
                              : 'Aucun dépistage enregistré',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          daysSinceLastScreening != null && daysSinceLastScreening < 180
                              ? 'Statut à jour et rassurant. Recommandation : tous les 6 mois.'
                              : 'Pensez à réaliser un dépistage de routine gratuit en CeGIDD ou laboratoire.',
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu par onglet
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ─── Onglet 1 : Dépistages IST ──────────────────────────────
                screenings.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const IntimaAnimatedIllustration(
                                type: IntimaIllustrationType.shield,
                                size: 130,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun dépistage enregistré',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Gardez l\'esprit tranquille en archivant vos dates de tests et vos rappels périodiques.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Enregistrer un test'),
                                onPressed: () => context.push('/sexual-health/screening/new'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: screenings.length,
                        itemBuilder: (context, i) {
                          final sc = screenings[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: IntimaCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: sc.status == ScreeningStatus.negative
                                              ? AppColors.success.withValues(alpha: 0.15)
                                              : (sc.status == ScreeningStatus.pending
                                                  ? Colors.orange.withValues(alpha: 0.15)
                                                  : AppColors.error.withValues(alpha: 0.15)),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          sc.status.labelFr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: sc.status == ScreeningStatus.negative
                                                ? AppColors.success
                                                : (sc.status == ScreeningStatus.pending ? Colors.orange : AppColors.error),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        dateFormat.format(sc.date),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (val) {
                                          if (val == 'delete') {
                                            ref.read(sexualHealthProvider.notifier).deleteScreening(sc.id);
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Supprimer', style: TextStyle(color: AppColors.error)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (sc.laboratoryOrClinic != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      sc.laboratoryOrClinic!,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: sc.testedStis
                                        .map((sti) => Chip(
                                              label: Text(sti, style: const TextStyle(fontSize: 11)),
                                              visualDensity: VisualDensity.compact,
                                              padding: EdgeInsets.zero,
                                            ))
                                        .toList(),
                                  ),
                                  if (sc.notes != null && sc.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      sc.notes!,
                                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                // ─── Onglet 2 : Vaccinations ────────────────────────────────
                vaccinations.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const IntimaAnimatedIllustration(
                                type: IntimaIllustrationType.shield,
                                size: 130,
                                primaryColor: Color(0xFF2D5A46),
                                secondaryColor: AppColors.sage,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun vaccin préventif enregistré',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Suivez votre schéma vaccinal (HPV Gardasil 9, Hépatite B) et ne manquez aucun rappel.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2D5A46),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Enregistrer un vaccin'),
                                onPressed: () => context.push('/sexual-health/vaccine/new'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: vaccinations.length,
                        itemBuilder: (context, i) {
                          final vac = vaccinations[i];
                          final pct = (vac.doseNumber / vac.totalDoses).clamp(0.0, 1.0);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: IntimaCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          vac.vaccineName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                        onPressed: () => ref.read(sexualHealthProvider.notifier).deleteVaccination(vac.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Dose ${vac.doseNumber} sur ${vac.totalDoses} • Administrée le ${dateFormat.format(vac.dateAdministered)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 6,
                                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D5A46)),
                                    ),
                                  ),
                                  if (vac.nextDoseDate != null && !vac.isCompleted) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.alarm_on_rounded, size: 14, color: AppColors.accent),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Prochaine dose recommandée : ${dateFormat.format(vac.nextDoseDate!)}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                // ─── Onglet 3 : PrEP & Prévention ───────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      IntimaCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shield_rounded, color: AppColors.primary, size: 24),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Prophylaxie Pré-Exposition (PrEP VIH)',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _showPrepModal(context, prep),
                                  child: const Text('Modifier'),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Protocole actif'),
                              subtitle: Text(prep.regimen.labelFr, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Bilan rénal / Créatinine'),
                              subtitle: Text(prep.nextKidneyCheckDate != null
                                  ? 'Rappel programmé pour le ${dateFormat.format(prep.nextKidneyCheckDate!)}'
                                  : 'Pas de date définie'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      IntimaCard(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Bon à savoir', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'La PrEP protège efficacement contre le VIH mais ne dispense pas des dépistages réguliers pour les autres IST (Chlamydia, Gonorrhée, Syphilis). Tous vos suivis restent 100% privés et stockés sur votre appareil.',
                              style: TextStyle(fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          if (_tabController.index == 1) {
            context.push('/sexual-health/vaccine/new');
          } else {
            context.push('/sexual-health/screening/new');
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

