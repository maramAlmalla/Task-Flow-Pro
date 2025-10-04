import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NoteLocalDataSource {
  final Box<NoteModel> box;

  NoteLocalDataSource(this.box);

  Future<List<NoteModel>> getAllNotes() async {
    return box.values.toList();
  }

  Future<NoteModel?> getNoteById(String id) async {
    return box.get(id);
  }

  Future<void> addNote(NoteModel note) async {
    await box.put(note.id, note);
  }

  Future<void> updateNote(NoteModel note) async {
    await box.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await box.delete(id);
  }

  Future<List<NoteModel>> searchNotes(String query) async {
    final allNotes = box.values.toList();
    final lowercaseQuery = query.toLowerCase();
    
    return allNotes.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
             note.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
