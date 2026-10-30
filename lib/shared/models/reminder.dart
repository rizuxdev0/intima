/// Modèle d'un rappel / notification locale dans INTIMA.
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.createdAt,
    this.description,
    this.scheduledTime,
    this.frequency = ReminderFrequency.once,
    this.endDate,
    this.category = ReminderCategory.personal,
    this.discretionLevel = 0,
    this.isActive = true,
    this.notificationId,
    this.linkedEncounterId,
    this.linkedPartnerId,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime scheduledDate;
  final String? scheduledTime;
  final ReminderFrequency frequency;
  final DateTime? endDate;
  final ReminderCategory category;

  /// 0 = discret, 1 = personnalisé, 2 = détaillé
  final int discretionLevel;
  final bool isActive;
  final int? notificationId;
  final String? linkedEncounterId;
  final String? linkedPartnerId;
  final DateTime createdAt;

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledDate,
    String? scheduledTime,
    ReminderFrequency? frequency,
    DateTime? endDate,
    ReminderCategory? category,
    int? discretionLevel,
    bool? isActive,
    int? notificationId,
    String? linkedEncounterId,
    String? linkedPartnerId,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      frequency: frequency ?? this.frequency,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      discretionLevel: discretionLevel ?? this.discretionLevel,
      isActive: isActive ?? this.isActive,
      notificationId: notificationId ?? this.notificationId,
      linkedEncounterId: linkedEncounterId ?? this.linkedEncounterId,
      linkedPartnerId: linkedPartnerId ?? this.linkedPartnerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'scheduledDate': scheduledDate.toIso8601String(),
        'scheduledTime': scheduledTime,
        'frequency': frequency.index,
        'endDate': endDate?.toIso8601String(),
        'category': category.index,
        'discretionLevel': discretionLevel,
        'isActive': isActive,
        'notificationId': notificationId,
        'linkedEncounterId': linkedEncounterId,
        'linkedPartnerId': linkedPartnerId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        scheduledDate: DateTime.parse(json['scheduledDate'] as String),
        scheduledTime: json['scheduledTime'] as String?,
        frequency: ReminderFrequency.values[json['frequency'] as int? ?? 0],
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        category: ReminderCategory.values[json['category'] as int? ?? 0],
        discretionLevel: json['discretionLevel'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
        notificationId: json['notificationId'] as int?,
        linkedEncounterId: json['linkedEncounterId'] as String?,
        linkedPartnerId: json['linkedPartnerId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Reminder && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

enum ReminderFrequency { once, daily, weekly, monthly }

enum ReminderCategory { personal, cycle, health, medical }

