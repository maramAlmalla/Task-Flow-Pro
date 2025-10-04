class Note {
  final String id;
  final String title;
  final String content;
  final bool isImportant;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.isImportant,
    required this.createdAt,
    this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isImportant,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isImportant: isImportant ?? this.isImportant,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
