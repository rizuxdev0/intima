import 'journal_attachment.dart';
import 'journal_mood.dart';

/// Modèle principal d'une entrée de Journal Intime.
///
/// Entièrement sérialisable en JSON chiffré AES-256-GCM localement.
class JournalEntry {
  const JournalEntry({
    required this.id,
    this.title,
    required this.content,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.mood = JournalMoodType.peaceful,
    this.moodIntensity = 3,
    this.categoryId = 'cat_personal',
    this.tags = const [],
    this.attachments = const [],
    this.isFavorite = false,
    this.isArchived = false,
    this.isDraft = false,
    this.notes,
  });

  final String id;
  final String? title;
  final String content;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final JournalMoodType mood;
  final int moodIntensity; // 1 (très doux) à 5 (très intense)
  final String categoryId;
  final List<String> tags;
  final List<JournalAttachment> attachments;
  final bool isFavorite;
  final bool isArchived;
  final bool isDraft;
  final String? notes;

  /// Titre d'affichage (utilise le titre s'il existe, sinon les premiers mots du contenu).
  String get displayTitle {
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }
    final clean = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.isEmpty) return 'Sans titre';
    return clean.length > 40 ? '${clean.substring(0, 40)}...' : clean;
  }

  /// Extrait textuel pour les cartes d'aperçu.
  String get previewSnippet {
    final clean = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length > 120) {
      return '${clean.substring(0, 120)}...';
    }
    return clean;
  }

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    JournalMoodType? mood,
    int? moodIntensity,
    String? categoryId,
    List<String>? tags,
    List<JournalAttachment>? attachments,
    bool? isFavorite,
    bool? isArchived,
    bool? isDraft,
    String? notes,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mood: mood ?? this.mood,
      moodIntensity: moodIntensity ?? this.moodIntensity,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isDraft: isDraft ?? this.isDraft,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'mood': mood.name,
        'moodIntensity': moodIntensity,
        'categoryId': categoryId,
        'tags': tags,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'isFavorite': isFavorite,
        'isArchived': isArchived,
        'isDraft': isDraft,
        'notes': notes,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        title: json['title'] as String?,
        content: json['content'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        mood: JournalMoodType.fromString(json['mood'] as String?),
        moodIntensity: (json['moodIntensity'] as int?)?.clamp(1, 5) ?? 3,
        categoryId: json['categoryId'] as String? ?? 'cat_personal',
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((e) => JournalAttachment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        isFavorite: json['isFavorite'] as bool? ?? false,
        isArchived: json['isArchived'] as bool? ?? false,
        isDraft: json['isDraft'] as bool? ?? false,
        notes: json['notes'] as String?,
      );
}

