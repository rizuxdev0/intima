import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_theme.dart';
import '../domain/models/journal_attachment.dart';
import '../domain/models/journal_category.dart';
import '../domain/models/journal_mood.dart';
import '../providers/journal_categories_provider.dart';
import '../providers/journal_provider.dart';
import 'widgets/journal_mood_selector.dart';
import 'widgets/journal_text_toolbar.dart';

/// Écran de création et d'édition d'une entrée de Journal Intime.
///
/// Comprend :
/// - Titre facultatif et contenu textuel riche
/// - Barre d'outils de formatage (Gras, Italique, Listes, Citations)
/// - Sélecteur d'émotion et réglette d'intensité
/// - Choix de catégorie et ajout de tags
/// - Ajout de photos
/// - Sauvegarde en brouillon ou publication définitive
class JournalEditorScreen extends ConsumerStatefulWidget {
  const JournalEditorScreen({super.key, this.entryId});

  final String? entryId;

  @override
  ConsumerState<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagInputController;
  late final TextEditingController _notesController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  JournalMoodType _selectedMood = JournalMoodType.peaceful;
  int _moodIntensity = 3;
  String _selectedCategoryId = 'cat_personal';
  final List<String> _tags = [];
  final List<JournalAttachment> _attachments = [];
  bool _isFavorite = false;
  bool _isDraft = false;

  bool _isLoading = false;
  bool _isInitialized = false;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _tagInputController = TextEditingController();
    _notesController = TextEditingController();

    // Démarrage de la sauvegarde automatique en arrière-plan toutes les 45 secondes
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 45), (_) => _autoSaveDraft());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadExistingEntryIfNeeded();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadExistingEntryIfNeeded() {
    if (widget.entryId == null) return;

    final entries = ref.read(journalEntriesProvider).valueOrNull ?? [];
    final existing = entries.firstWhere(
      (e) => e.id == widget.entryId,
      orElse: () => throw Exception('Entrée non trouvée'),
    );

    _titleController.text = existing.title ?? '';
    _contentController.text = existing.content;
    _notesController.text = existing.notes ?? '';
    _selectedDate = existing.date;
    _selectedTime = TimeOfDay.fromDateTime(existing.createdAt);
    _selectedMood = existing.mood;
    _moodIntensity = existing.moodIntensity;
    _selectedCategoryId = existing.categoryId;
    _tags.addAll(existing.tags);
    _attachments.addAll(existing.attachments);
    _isFavorite = existing.isFavorite;
    _isDraft = existing.isDraft;
    setState(() {});
  }

  void _autoSaveDraft() {
    if (_contentController.text.trim().isEmpty || widget.entryId != null) return;
    // Sauvegarde discrète
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _addTag(String tag) {
    final clean = tag.trim().replaceAll('#', '');
    if (clean.isNotEmpty && !_tags.contains(clean)) {
      setState(() {
        _tags.add(clean);
        _tagInputController.clear();
      });
    }
  }

  void _addSamplePhoto() {
    final now = DateTime.now();
    setState(() {
      _attachments.add(
        JournalAttachment(
          id: 'att_${now.millisecondsSinceEpoch}',
          fileName: 'photo_${_attachments.length + 1}.jpg',
          localPath: 'sample_asset_${_attachments.length + 1}',
          createdAt: now,
          caption: 'Souvenir visuel',
        ),
      );
    });
  }

  Future<void> _saveEntry({bool saveAsDraft = false}) async {
    final content = _contentController.text.trim();
    if (content.isEmpty && !saveAsDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez écrire quelques mots avant d\'enregistrer.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final notifier = ref.read(journalEntriesProvider.notifier);

      if (widget.entryId != null) {
        final existingEntries = ref.read(journalEntriesProvider).valueOrNull ?? [];
        final existing = existingEntries.firstWhere((e) => e.id == widget.entryId);
        final updated = existing.copyWith(
          title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
          content: content,
          date: combinedDateTime,
          mood: _selectedMood,
          moodIntensity: _moodIntensity,
          categoryId: _selectedCategoryId,
          tags: _tags,
          attachments: _attachments,
          isFavorite: _isFavorite,
          isDraft: saveAsDraft || _isDraft,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );
        await notifier.updateEntry(updated);
      } else {
        await notifier.addEntry(
          title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
          content: content.isNotEmpty ? content : 'Brouillon sans texte',
          date: combinedDateTime,
          mood: _selectedMood,
          moodIntensity: _moodIntensity,
          categoryId: _selectedCategoryId,
          tags: _tags,
          attachments: _attachments,
          isFavorite: _isFavorite,
          isDraft: saveAsDraft || _isDraft,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saveAsDraft
                ? 'Brouillon sauvegardé avec succès.'
                : 'Entrée enregistrée dans votre journal intime.'),
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
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('EEE d MMM yyyy', locale);

    final categoriesAsync = ref.watch(journalCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? JournalCategory.defaultCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entryId != null
              ? (locale == 'en' ? 'Edit Entry' : 'Modifier l\'écrit')
              : (locale == 'en' ? 'New Journal Entry' : 'Nouvelle entrée'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Enregistrer comme brouillon
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            tooltip: locale == 'en' ? 'Save Draft' : 'Sauvegarder brouillon',
            onPressed: _isLoading ? null : () => _saveEntry(saveAsDraft: true),
          ),
          // Bouton Publier / Sauvegarder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(locale == 'en' ? 'Save' : 'Enregistrer'),
              onPressed: _isLoading ? null : () => _saveEntry(saveAsDraft: false),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                children: [
                  // Sélecteur Date & Heure
                  Row(
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text(dateFormat.format(_selectedDate)),
                        onPressed: _pickDate,
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.access_time_rounded, size: 16),
                        label: Text(_selectedTime.format(context)),
                        onPressed: _pickTime,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          color: _isFavorite ? AppColors.primary : null,
                        ),
                        tooltip: 'Épingler aux favoris',
                        onPressed: () => setState(() => _isFavorite = !_isFavorite),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Sélecteur d'émotion & intensité
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: JournalMoodSelector(
                      selectedMood: _selectedMood,
                      intensity: _moodIntensity,
                      onMoodSelected: (m) => setState(() => _selectedMood = m),
                      onIntensityChanged: (i) => setState(() => _moodIntensity = i),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Choix de la catégorie
                  Text(
                    locale == 'en' ? 'Category' : 'Catégorie',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = cat.id == _selectedCategoryId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            avatar: Icon(cat.icon, size: 14, color: cat.color),
                            label: Text(cat.localizedName(locale)),
                            selected: isSelected,
                            selectedColor: cat.color.withValues(alpha: 0.22),
                            onSelected: (val) {
                              if (val) setState(() => _selectedCategoryId = cat.id);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Champ Titre
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: locale == 'en'
                          ? 'Title (optional)'
                          : 'Titre de votre pensée (facultatif)',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),

                  const SizedBox(height: 12),

                  // Barre d'outils de formatage
                  JournalTextToolbar(controller: _contentController),

                  const SizedBox(height: 10),

                  // Éditeur de contenu principal
                  TextField(
                    controller: _contentController,
                    maxLines: 12,
                    minLines: 7,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: locale == 'en'
                          ? 'Write freely what is in your heart...'
                          : 'Écrivez librement ce que vous avez sur le cœur...',
                      filled: true,
                      fillColor: isDark
                          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15)
                          : Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),

                  const SizedBox(height: 18),

                  // Tags / Mots-clés
                  Text(
                    locale == 'en' ? 'Keywords / Tags' : 'Mots-clés / Tags',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ..._tags.map(
                        (tag) => Chip(
                          label: Text('#$tag'),
                          onDeleted: () => setState(() => _tags.remove(tag)),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        height: 36,
                        child: TextField(
                          controller: _tagInputController,
                          decoration: const InputDecoration(
                            hintText: '+ Ajouter tag',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                          onSubmitted: _addTag,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Pièces jointes / Photos
                  Row(
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 20, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        locale == 'en' ? 'Photos & Memories' : 'Photos & Souvenirs',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                        label: Text(locale == 'en' ? 'Add photo' : 'Ajouter photo'),
                        onPressed: _addSamplePhoto,
                      ),
                    ],
                  ),

                  if (_attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _attachments.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final att = _attachments[i];
                          return Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.image_rounded, color: AppColors.primary),
                                      const SizedBox(height: 4),
                                      Text(
                                        att.fileName,
                                        style: const TextStyle(fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => setState(() => _attachments.removeAt(i)),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

