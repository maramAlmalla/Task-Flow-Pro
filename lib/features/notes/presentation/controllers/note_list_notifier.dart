import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import '../../domain/usecases/add_note_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/search_notes_usecase.dart';

class NoteListState {
  final bool isLoading;
  final List<Note> notes;
  final String? error;
  final String searchQuery;

  NoteListState({
    this.isLoading = false,
    this.notes = const [],
    this.error,
    this.searchQuery = '',
  });

  NoteListState copyWith({
    bool? isLoading,
    List<Note>? notes,
    String? error,
    String? searchQuery,
  }) {
    return NoteListState(
      isLoading: isLoading ?? this.isLoading,
      notes: notes ?? this.notes,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Note> get filteredNotes {
    if (searchQuery.isEmpty) return notes;
    return notes;
  }

  List<Note> get importantNotes => notes.where((n) => n.isImportant).toList();
}

class NoteListNotifier extends StateNotifier<NoteListState> {
  final GetNotesUseCase getNotesUseCase;
  final AddNoteUseCase addNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final SearchNotesUseCase searchNotesUseCase;

  NoteListNotifier({
    required this.getNotesUseCase,
    required this.addNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required this.searchNotesUseCase,
  }) : super(NoteListState());

  Future<void> loadNotes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notes = await getNotesUseCase();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(isLoading: false, notes: notes);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchNotes(String query) async {
    state = state.copyWith(searchQuery: query);
    if (query.isEmpty) {
      await loadNotes();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final notes = await searchNotesUseCase(query);
      state = state.copyWith(isLoading: false, notes: notes);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createNote(Note note) async {
    try {
      await addNoteUseCase(note);
      await loadNotes();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> editNote(Note note) async {
    try {
      await updateNoteUseCase(note);
      await loadNotes();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeNote(String id) async {
    try {
      await deleteNoteUseCase(id);
      await loadNotes();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleImportant(String id) async {
    final note = state.notes.firstWhere((n) => n.id == id);
    final updated = note.copyWith(
      isImportant: !note.isImportant,
      updatedAt: DateTime.now(),
    );
    await editNote(updated);
  }
}
