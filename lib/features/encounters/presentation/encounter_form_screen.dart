import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../shared/models/encounter.dart';
import '../../partners/providers/partners_provider.dart';
import '../providers/encounters_provider.dart';

class EncounterFormScreen extends ConsumerStatefulWidget {
  const EncounterFormScreen({super.key, this.encounterId});

  final String? encounterId;

  @override
  ConsumerState<EncounterFormScreen> createState() =>
      _EncounterFormScreenState();
}

class _EncounterFormScreenState extends ConsumerState<EncounterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _customTypeController = TextEditingController();
  final _durationController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  String? _selectedPartnerId;
  EncounterType _selectedType = EncounterType.intimate;
  ProtectionType? _protectionUsed;
  bool _protectionIssue = false;
  int? _moodBefore;
  int? _moodAfter;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.encounterId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final all = ref.read(encountersProvider).valueOrNull ?? [];
        try {
          final encounter = all.firstWhere((e) => e.id == widget.encounterId);
          setState(() {
            _selectedDate = encounter.date;
            _selectedPartnerId = encounter.partnerId;
            _selectedType = encounter.type;
            _customTypeController.text = encounter.customTypeName ?? '';
            _notesController.text = encounter.notes ?? '';
            if (encounter.durationMinutes != null) {
              _durationController.text = encounter.durationMinutes.toString();
            }
            _protectionUsed = encounter.protectionUsed;
            _protectionIssue = encounter.protectionIssue;
            _moodBefore = encounter.moodBefore;
            _moodAfter = encounter.moodAfter;
          });
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customTypeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final l10n = AppLocalizations.of(context);
    final duration = int.tryParse(_durationController.text.trim());

    try {
      if (widget.encounterId == null) {
        await ref.read(encountersProvider.notifier).addEncounter(
              date: _selectedDate,
              partnerId: _selectedPartnerId,
              time: _selectedTime != null
                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                  : null,
              durationMinutes: duration,
              type: _selectedType,
              customTypeName: _selectedType == EncounterType.custom
                  ? _customTypeController.text.trim()
                  : null,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              moodBefore: _moodBefore,
              moodAfter: _moodAfter,
              protectionUsed: _protectionUsed,
              protectionIssue: _protectionIssue,
            );
      } else {
        final all = ref.read(encountersProvider).valueOrNull ?? [];
        final existing = all.firstWhere((e) => e.id == widget.encounterId);
        final updated = existing.copyWith(
          date: _selectedDate,
          partnerId: _selectedPartnerId,
          durationMinutes: duration,
          type: _selectedType,
          customTypeName: _selectedType == EncounterType.custom
              ? _customTypeController.text.trim()
              : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          moodBefore: _moodBefore,
          moodAfter: _moodAfter,
          protectionUsed: _protectionUsed,
          protectionIssue: _protectionIssue,
        );
        await ref.read(encountersProvider.notifier).updateEncounter(updated);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.encounterId == null
                  ? l10n.toastSaved
                  : l10n.toastChangesSaved,
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final partners = ref.watch(partnersProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.encounterId == null
              ? l10n.encountersAdd
              : l10n.encounterDetail,
        ),
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Date & Heure
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(l10n.encounterDate),
              subtitle: Text(du.DateUtils.formatDate(_selectedDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            const Divider(),

            // Partenaire (optionnel)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.encounterPartner),
              subtitle: Text(
                _selectedPartnerId != null
                    ? (partners
                            .where((p) => p.id == _selectedPartnerId)
                            .firstOrNull
                            ?.displayName ??
                        l10n.commonOptional)
                    : l10n.commonOptional,
              ),
              trailing: DropdownButton<String?>(
                value: _selectedPartnerId,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.commonNone),
                  ),
                  ...partners.map((p) {
                    return DropdownMenuItem<String?>(
                      value: p.id,
                      child: Text(p.displayName),
                    );
                  }),
                ],
                onChanged: (val) => setState(() => _selectedPartnerId = val),
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Type d'événement
            Text(
              l10n.encounterType,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.encounterTypeIntimate),
                  selected: _selectedType == EncounterType.intimate,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = EncounterType.intimate);
                    }
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.encounterTypePersonal),
                  selected: _selectedType == EncounterType.personal,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = EncounterType.personal);
                    }
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.encounterTypeCustom),
                  selected: _selectedType == EncounterType.custom,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = EncounterType.custom);
                    }
                  },
                ),
              ],
            ),
            if (_selectedType == EncounterType.custom) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _customTypeController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'événement',
                  hintText: 'Ex: Soirée romantique',
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Durée (minutes)
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${l10n.encounterDuration} (minutes)',
                hintText: 'Ex: 30',
                prefixIcon: const Icon(Icons.timer_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // Protection utilisée (facultative)
            Text(
              l10n.encounterProtection,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Préservatif'),
                  selected: _protectionUsed == ProtectionType.condom,
                  onSelected: (selected) {
                    setState(() {
                      _protectionUsed = selected ? ProtectionType.condom : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Autre'),
                  selected: _protectionUsed == ProtectionType.other,
                  onSelected: (selected) {
                    setState(() {
                      _protectionUsed = selected ? ProtectionType.other : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Aucune'),
                  selected: _protectionUsed == ProtectionType.none,
                  onSelected: (selected) {
                    setState(() {
                      _protectionUsed = selected ? ProtectionType.none : null;
                    });
                  },
                ),
              ],
            ),
            if (_protectionUsed == ProtectionType.condom) ...[
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.encounterProtectionIssue),
                value: _protectionIssue,
                onChanged: (val) => setState(() => _protectionIssue = val ?? false),
              ),
            ],
            const SizedBox(height: 24),

            // Humeur avant / après (1-5)
            Text(
              '${l10n.encounterMoodBefore} (${l10n.commonOptional})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _MoodSelector(
              selectedMood: _moodBefore,
              onMoodSelected: (val) => setState(() => _moodBefore = val),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.encounterMoodAfter} (${l10n.commonOptional})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _MoodSelector(
              selectedMood: _moodAfter,
              onMoodSelected: (val) => setState(() => _moodAfter = val),
            ),
            const SizedBox(height: 24),

            // Notes personnelles
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: '${l10n.encounterNotes} (${l10n.commonOptional})',
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(Icons.note_alt_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({
    required this.selectedMood,
    required this.onMoodSelected,
  });

  final int? selectedMood;
  final ValueChanged<int?> onMoodSelected;

  static const _moodIcons = [
    Icons.sentiment_very_dissatisfied_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.sentiment_satisfied_rounded,
    Icons.sentiment_very_satisfied_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final rating = index + 1;
        final isSelected = selectedMood == rating;
        return IconButton(
          icon: Icon(
            _moodIcons[index],
            color: isSelected ? AppColors.primary : Colors.grey,
            size: 32,
          ),
          onPressed: () {
            onMoodSelected(isSelected ? null : rating);
          },
        );
      }),
    );
  }
}

