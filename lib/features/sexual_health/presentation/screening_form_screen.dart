import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_theme.dart';
import '../../partners/providers/partners_provider.dart';
import '../domain/models/sti_screening.dart';
import '../providers/sexual_health_provider.dart';

/// Formulaire d'enregistrement d'un test de dépistage IST.
class ScreeningFormScreen extends ConsumerStatefulWidget {
  const ScreeningFormScreen({super.key, this.screeningId});

  final String? screeningId;

  @override
  ConsumerState<ScreeningFormScreen> createState() => _ScreeningFormScreenState();
}

class _ScreeningFormScreenState extends ConsumerState<ScreeningFormScreen> {
  DateTime _date = DateTime.now();
  late final TextEditingController _labController;
  late final TextEditingController _notesController;

  ScreeningStatus _status = ScreeningStatus.negative;
  final Set<String> _testedStis = {
    'VIH',
    'Chlamydia',
    'Gonorrhée',
    'Syphilis',
    'Hépatite B',
    'Hépatite C',
  };

  String? _selectedPartnerId;
  String? _selectedPartnerName;
  DateTime? _nextReminderDate;
  bool _isLoading = false;

  final List<String> _availableStis = [
    'VIH',
    'Chlamydia',
    'Gonorrhée',
    'Syphilis',
    'Hépatite B',
    'Hépatite C',
    'Mycoplasma genitalium',
    'Trichomonase',
    'HPV (Papillomavirus)',
    'Herpès HSV',
  ];

  @override
  void initState() {
    super.initState();
    _labController = TextEditingController();
    _notesController = TextEditingController();
    // Par défaut, proposer un prochain rappel dans 6 mois
    _nextReminderDate = DateTime.now().add(const Duration(days: 180));
  }

  @override
  void dispose() {
    _labController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickReminderDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextReminderDate ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _nextReminderDate = picked);
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      const uuid = Uuid();
      final screening = StiScreening(
        id: widget.screeningId ?? uuid.v4(),
        date: _date,
        laboratoryOrClinic: _labController.text.trim().isNotEmpty
            ? _labController.text.trim()
            : null,
        status: _status,
        testedStis: _testedStis.toList(),
        partnerId: _selectedPartnerId,
        partnerName: _selectedPartnerName,
        nextReminderDate: _nextReminderDate,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdAt: DateTime.now(),
      );

      await ref.read(sexualHealthProvider.notifier).saveScreening(screening);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dépistage enregistré avec succès dans votre carnet chiffré.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat('EEEE d MMMM yyyy', locale);
    final partnersAsync = ref.watch(partnersProvider);
    final partners = partnersAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau dépistage IST', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _isLoading ? null : _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Date du prélèvement
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_rounded, color: AppColors.primary),
            title: const Text('Date du prélèvement / test'),
            subtitle: Text(dateFormat.format(_date)),
            trailing: OutlinedButton(
              onPressed: _pickDate,
              child: const Text('Changer'),
            ),
          ),

          const SizedBox(height: 12),

          // Résultat global
          Text('Résultat global', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<ScreeningStatus>(
            segments: const [
              ButtonSegment(
                value: ScreeningStatus.negative,
                label: Text('Négatif'),
                icon: Icon(Icons.check_circle_outline, color: AppColors.success),
              ),
              ButtonSegment(
                value: ScreeningStatus.pending,
                label: Text('En attente'),
                icon: Icon(Icons.hourglass_empty_rounded, color: Colors.orange),
              ),
              ButtonSegment(
                value: ScreeningStatus.positive,
                label: Text('Positif'),
                icon: Icon(Icons.warning_amber_rounded, color: AppColors.error),
              ),
            ],
            selected: {_status},
            onSelectionChanged: (set) => setState(() => _status = set.first),
          ),

          const SizedBox(height: 20),

          // Laboratoire ou Centre
          TextField(
            controller: _labController,
            decoration: InputDecoration(
              labelText: 'Laboratoire ou Centre (CeGIDD, Hôpital, etc.)',
              hintText: 'Ex: Laboratoire Bio-Santé / CeGIDD Saint-Louis',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.local_hospital_outlined),
            ),
          ),

          const SizedBox(height: 20),

          // Pathogènes et IST testés
          Text('IST testées lors de ce bilan', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableStis.map((sti) {
              final isChecked = _testedStis.contains(sti);
              return FilterChip(
                label: Text(sti),
                selected: isChecked,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _testedStis.add(sti);
                    } else {
                      _testedStis.remove(sti);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Partenaire associé facultatif
          if (partners.isNotEmpty) ...[
            Text('Partenaire lié (facultatif)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _selectedPartnerId,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              hint: const Text('Aucun partenaire spécifique'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Aucun (Bilan personnel)'),
                ),
                ...partners.map(
                  (p) => DropdownMenuItem<String?>(
                    value: p.id,
                    child: Text('${p.emoji ?? '👤'} ${p.name}'),
                  ),
                ),
              ],
              onChanged: (id) {
                setState(() {
                  _selectedPartnerId = id;
                  _selectedPartnerName = partners.cast().firstWhere((p) => p.id == id, orElse: () => null)?.name;
                });
              },
            ),
            const SizedBox(height: 20),
          ],

          // Prochain rappel de dépistage
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alarm_on_rounded, color: AppColors.accent),
            title: const Text('Prochain dépistage recommandé'),
            subtitle: Text(_nextReminderDate != null
                ? dateFormat.format(_nextReminderDate!)
                : 'Pas de rappel programmé'),
            trailing: OutlinedButton(
              onPressed: _pickReminderDate,
              child: const Text('Définir'),
            ),
          ),

          const SizedBox(height: 16),

          // Notes complémentaires
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes ou recommandations médicales',
              hintText: 'Ex: Traitement antibiotique préventif prescrit, prise de sang de contrôle...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_rounded),
              label: const Text('Enregistrer le dépistage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _isLoading ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}

