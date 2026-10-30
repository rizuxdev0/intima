/// Pièce jointe d'une entrée de journal (photo ou note visuelle).
class JournalAttachment {
  const JournalAttachment({
    required this.id,
    required this.fileName,
    required this.localPath,
    required this.createdAt,
    this.caption,
  });

  final String id;
  final String fileName;
  final String localPath;
  final DateTime createdAt;
  final String? caption;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'localPath': localPath,
        'createdAt': createdAt.toIso8601String(),
        'caption': caption,
      };

  factory JournalAttachment.fromJson(Map<String, dynamic> json) =>
      JournalAttachment(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        localPath: json['localPath'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        caption: json['caption'] as String?,
      );
}

