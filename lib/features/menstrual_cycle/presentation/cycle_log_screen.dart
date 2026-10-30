import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../providers/menstrual_cycle_provider.dart';

class CycleLogScreen extends ConsumerStatefulWidget {
  const CycleLogScreen({super.key});

  @override
  ConsumerState<CycleLogScreen> createState() => _CycleLogScreenState();
}

class _CycleLogScreenState extends ConsumerState<CycleLogScreen> {
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  int? _flowIntensity;
  final _obsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context);

    try {
      final cycle = await ref.read(menstrualCycleProvider.notifier).startCycle(
            startDate: _startDate,
            flowIntensity: _flowIntensity,
            observations: _obsController.text.trim().isEmpty
                ? null
                : _obsController.text.trim(),
          );

      if (_endDate != null) {
        await ref
            .read(menstrualCycleProvider.notifier)
            .updateCycle(cycle.copyWith(endDate: _endDate));
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cycleLogPeriod),
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
          // Premier jour des règles
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(l10n.cyclePeriodStart),
            subtitle: Text(du.DateUtils.formatDate(_startDate)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _startDate = picked);
              }
            },
          ),
          const Divider(),

          // Dernier jour des règles (facultatif)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available_outlined),
            title: Text(l10n.cyclePeriodEnd),
            subtitle: Text(
              _endDate != null
                  ? du.DateUtils.formatDate(_endDate!)
                  : l10n.commonOptional,
            ),
            trailing: _endDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _endDate = null),
                  )
                : const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _endDate ?? _startDate.add(const Duration(days: 4)),
                firstDate: _startDate,
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _endDate = picked);
              }
            },
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Intensité du flux
          Text(
            l10n.cycleFlowIntensity,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.cycleFlowLight),
                selected: _flowIntensity == 0,
                onSelected: (val) {
                  setState(() => _flowIntensity = val ? 0 : null);
                },
              ),
              ChoiceChip(
                label: Text(l10n.cycleFlowMedium),
                selected: _flowIntensity == 1,
                onSelected: (val) {
                  setState(() => _flowIntensity = val ? 1 : null);
                },
              ),
              ChoiceChip(
                label: Text(l10n.cycleFlowHeavy),
                selected: _flowIntensity == 2,
                onSelected: (val) {
                  setState(() => _flowIntensity = val ? 2 : null);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Observations libres
          TextFormField(
            controller: _obsController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: '${l10n.cycleObservations} (${l10n.commonOptional})',
              alignLabelWithHint: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 64),
                child: Icon(Icons.note_alt_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

