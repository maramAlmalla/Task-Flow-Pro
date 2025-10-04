import '../repositories/note_repository.dart';

class DeleteNoteUseCase {
  final NoteRepository repository;

  DeleteNoteUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteNote(id);
  }
}
