import '../entities/note.dart';
import '../repositories/note_repository.dart';

class SearchNotesUseCase {
  final NoteRepository repository;

  SearchNotesUseCase(this.repository);

  Future<List<Note>> call(String query) async {
    return await repository.searchNotes(query);
  }
}
