import 'package:hive/hive.dart';
import '../../domain/entities/note.dart';

part 'note_model.g.dart';

@HiveType(typeId: 2)
class NoteModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  bool isImportant;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.isImportant,
    required this.createdAt,
    this.updatedAt,
  });

  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      isImportant: isImportant,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      isImportant: note.isImportant,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }
}
