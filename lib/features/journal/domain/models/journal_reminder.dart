/// Configuration d'un rappel d'écriture du Journal Intime.
class JournalReminder {
  const JournalReminder({
    required this.id,
    required this.time, // format "HH:mm"
    required this.repeatDays, // 1 = Lundi, 7 = Dimanche. Liste vide = tous les jours
    required this.message,
    this.isActive = true,
    this.discretionLevel = 0,
    required this.createdAt,
  });

  final String id;
  final String time;
  final List<int> repeatDays;
  final String message;
  final bool isActive;
  final int discretionLevel;
  final DateTime createdAt;

  int get hour => int.parse(time.split(':').first);
  int get minute => int.parse(time.split(':').last);

  JournalReminder copyWith({
    String? id,
    String? time,
    List<int>? repeatDays,
    String? message,
    bool? isActive,
    int? discretionLevel,
    DateTime? createdAt,
  }) {
    return JournalReminder(
      id: id ?? this.id,
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
      message: message ?? this.message,
      isActive: isActive ?? this.isActive,
      discretionLevel: discretionLevel ?? this.discretionLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time,
        'repeatDays': repeatDays,
        'message': message,
        'isActive': isActive,
        'discretionLevel': discretionLevel,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JournalReminder.fromJson(Map<String, dynamic> json) =>
      JournalReminder(
        id: json['id'] as String,
        time: json['time'] as String? ?? '21:00',
        repeatDays: (json['repeatDays'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            const [1, 2, 3, 4, 5, 6, 7],
        message: json['message'] as String? ??
            'Prends quelques minutes pour noter tes pensées.',
        isActive: json['isActive'] as bool? ?? true,
        discretionLevel: json['discretionLevel'] as int? ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}

