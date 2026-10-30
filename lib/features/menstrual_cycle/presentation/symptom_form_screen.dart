import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../shared/models/menstrual_cycle.dart';
import '../providers/menstrual_cycle_provider.dart';

class SymptomFormScreen extends ConsumerStatefulWidget {
  const SymptomFormScreen({super.key});

  @override
  ConsumerState<SymptomFormScreen> createState() => _SymptomFormScreenState();
}

class _SymptomFormScreenState extends ConsumerState<SymptomFormScreen> {
  DateTime _date = DateTime.now();
  SymptomType _selectedType = SymptomType.cramps;
  int _intensity = 3;
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context);

    try {
      final cycles = ref.read(menstrualCycleProvider).valueOrNull ?? [];
      if (cycles.isNotEmpty) {
        final currentCycle = cycles.first;
        final symptom = CycleSymptom(
          date: _date,
          type: _selectedType,
          intensity: _intensity,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
        await ref
            .read(menstrualCycleProvider.notifier)
            .addSymptom(currentCycle.id, symptom);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.toastSaved)),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.toastError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getSymptomLabel(SymptomType type, AppLocalizations l10n) {
    switch (type) {
      case SymptomType.cramps:
        return l10n.cycleCramps;
      case SymptomType.fatigue:
        return l10n.cycleFatigue;
      case SymptomType.headache:
        return l10n.cycleHeadache;
      case SymptomType.moodSwings:
        return l10n.cycleMood;
      case SymptomType.insomnia:
        return l10n.cycleSleep;
      default:
        return type.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cycleSymptomsAdd),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.commonSave),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Date
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Date'),
            subtitle: Text(du.DateUtils.formatDate(_date)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _date = picked);
              }
            },
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Type de symptôme
          Text(
            l10n.cycleSymptoms,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              SymptomType.cramps,
              SymptomType.fatigue,
              SymptomType.headache,
              SymptomType.moodSwings,
              SymptomType.insomnia,
              SymptomType.bloating,
              SymptomType.backPain,
              SymptomType.nausea,
            ].map((type) {
              return ChoiceChip(
                label: Text(_getSymptomLabel(type, l10n)),
                selected: _selectedType == type,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedType = type);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Intensité (1-5)
          Text(
            'Intensité : $_intensity / 5',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Slider(
            value: _intensity.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '$_intensity',
            onChanged: (val) => setState(() => _intensity = val.round()),
          ),
          const SizedBox(height: 16),

          // Note
          TextFormField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: '${l10n.cycleObservations} (${l10n.commonOptional})',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: Icon(Icons.note_alt_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

