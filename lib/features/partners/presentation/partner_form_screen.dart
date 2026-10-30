import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/app_localizations.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../providers/partners_provider.dart';

class PartnerFormScreen extends ConsumerStatefulWidget {
  const PartnerFormScreen({super.key, this.partnerId});

  final String? partnerId;

  @override
  ConsumerState<PartnerFormScreen> createState() => _PartnerFormScreenState();
}

class _PartnerFormScreenState extends ConsumerState<PartnerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagController = TextEditingController();

  int _selectedColor = AppColors.partnerColors[0].toARGB32();
  DateTime? _firstMetDate;
  List<String> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.partnerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final partner =
            ref.read(partnersProvider.notifier).findById(widget.partnerId!);
        if (partner != null) {
          setState(() {
            _nameController.text = partner.name ?? '';
            _notesController.text = partner.notes ?? '';
            _selectedColor = partner.color;
            _firstMetDate = partner.firstMetDate;
            _tags = List.from(partner.tags);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final l10n = AppLocalizations.of(context);

    try {
      if (widget.partnerId == null) {
        await ref.read(partnersProvider.notifier).addPartner(
              name: _nameController.text.trim().isEmpty
                  ? null
                  : _nameController.text.trim(),
              color: _selectedColor,
              firstMetDate: _firstMetDate,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              tags: _tags,
            );
      } else {
        final existing =
            ref.read(partnersProvider.notifier).findById(widget.partnerId!);
        if (existing != null) {
          final updated = existing.copyWith(
            name: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
            color: _selectedColor,
            firstMetDate: _firstMetDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            tags: _tags,
          );
          await ref.read(partnersProvider.notifier).updatePartner(updated);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.partnerId == null
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

  void _addTag() {
    final text = _tagController.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.partnerId == null ? l10n.partnersAdd : l10n.partnerDetailTitle,
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
            // Nom / Pseudonyme
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${l10n.partnerName} (${l10n.commonOptional})',
                hintText: l10n.partnerNameHint,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 24),

            // Choix de couleur d'avatar
            Text(
              l10n.partnerColor,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppColors.partnerColors.map((color) {
                final isSelected = _selectedColor == color.toARGB32();
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color.toARGB32()),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Date de première rencontre
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(l10n.partnerFirstMet),
              subtitle: Text(
                _firstMetDate != null
                    ? du.DateUtils.formatDate(_firstMetDate!)
                    : l10n.commonOptional,
              ),
              trailing: _firstMetDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _firstMetDate = null),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _firstMetDate ?? DateTime.now(),
                  firstDate: DateTime(1970),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _firstMetDate = picked);
                }
              },
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Étiquettes
            Text(
              l10n.partnerTags,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter une étiquette',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _addTag,
                      ),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() => _tags.remove(tag));
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),

            // Notes personnelles
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: '${l10n.partnerNotes} (${l10n.commonOptional})',
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

