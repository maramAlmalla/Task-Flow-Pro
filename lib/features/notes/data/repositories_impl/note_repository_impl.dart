import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_data_source.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;

  NoteRepositoryImpl(this.localDataSource);

  @override
  Future<List<Note>> getAllNotes() async {
    final models = await localDataSource.getAllNotes();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final model = await localDataSource.getNoteById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addNote(Note note) async {
    final model = NoteModel.fromEntity(note);
    await localDataSource.addNote(model);
  }

  @override
  Future<void> updateNote(Note note) async {
    final model = NoteModel.fromEntity(note);
    await localDataSource.updateNote(model);
  }

  @override
  Future<void> deleteNote(String id) async {
    await localDataSource.deleteNote(id);
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    final models = await localDataSource.searchNotes(query);
    return models.map((model) => model.toEntity()).toList();
  }
}
