import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../app/theme/app_theme.dart';
import '../domain/models/vaccination_record.dart';
import '../providers/sexual_health_provider.dart';

/// Formulaire d'enregistrement d'une dose de vaccin préventif.
class VaccinationFormScreen extends ConsumerStatefulWidget {
  const VaccinationFormScreen({super.key, this.recordId});

  final String? recordId;

  @override
  ConsumerState<VaccinationFormScreen> createState() => _VaccinationFormScreenState();
}

class _VaccinationFormScreenState extends ConsumerState<VaccinationFormScreen> {
  String _vaccineName = 'HPV (Papillomavirus - Gardasil 9)';
  int _doseNumber = 1;
  int _totalDoses = 3;
  DateTime _dateAdministered = DateTime.now();
  DateTime? _nextDoseDate;
  late final TextEditingController _notesController;
  bool _isLoading = false;

  final List<String> _suggestedVaccines = [
    'HPV (Papillomavirus - Gardasil 9)',
    'Hépatite B',
    'Hépatite A',
    'Mpox (Variole simienne)',
    'Méningocoque B',
    'Autre vaccin préventif',
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    // Proposer une deuxième dose à +2 mois par défaut
    _nextDoseDate = DateTime.now().add(const Duration(days: 60));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAdministeredDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateAdministered,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateAdministered = picked);
  }

  Future<void> _pickNextDoseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDoseDate ?? DateTime.now().add(const Duration(days: 60)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _nextDoseDate = picked);
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      const uuid = Uuid();
      final record = VaccinationRecord(
        id: widget.recordId ?? uuid.v4(),
        vaccineName: _vaccineName,
        doseNumber: _doseNumber,
        totalDoses: _totalDoses,
        dateAdministered: _dateAdministered,
        nextDoseDate: _doseNumber < _totalDoses ? _nextDoseDate : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdAt: DateTime.now(),
      );

      await ref.read(sexualHealthProvider.notifier).saveVaccination(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination enregistrée dans votre carnet de santé.'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer un vaccin', style: TextStyle(fontWeight: FontWeight.bold)),
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
          Text('Nom du vaccin', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _vaccineName,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              prefixIcon: const Icon(Icons.vaccines_outlined, color: AppColors.primary),
            ),
            items: _suggestedVaccines
                .map((v) => DropdownMenuItem(value: v, child: Text(v, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _vaccineName = val);
            },
          ),

          const SizedBox(height: 20),

          // Numéro de dose et total
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dose n°', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _doseNumber,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: [1, 2, 3, 4]
                          .map((n) => DropdownMenuItem(value: n, child: Text('Dose $n')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _doseNumber = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total requis', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: _totalDoses,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: [1, 2, 3]
                          .map((n) => DropdownMenuItem(value: n, child: Text('$n dose(s)')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _totalDoses = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Date d'administration
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available_rounded, color: AppColors.primary),
            title: const Text('Date d\'injection'),
            subtitle: Text(dateFormat.format(_dateAdministered)),
            trailing: OutlinedButton(
              onPressed: _pickAdministeredDate,
              child: const Text('Modifier'),
            ),
          ),

          const SizedBox(height: 12),

          // Prochaine dose si schéma non terminé
          if (_doseNumber < _totalDoses) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.alarm_on_rounded, color: AppColors.accent),
              title: Text('Date de rappel pour la dose ${_doseNumber + 1}'),
              subtitle: Text(_nextDoseDate != null ? dateFormat.format(_nextDoseDate!) : 'Non définie'),
              trailing: OutlinedButton(
                onPressed: _pickNextDoseDate,
                child: const Text('Planifier'),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Notes complémentaires
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'N° de lot ou lieu de vaccination (facultatif)',
              hintText: 'Ex: Cabinet Dr. Dupont / Lot #AB492',
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
              label: const Text('Valider l\'injection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _isLoading ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}

