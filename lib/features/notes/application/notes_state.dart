import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notes_provider.dart';
import '../data/notes_repository.dart';
import '../domain/note.dart';

final notesStateProvider =
    AsyncNotifierProvider<NotesStateNotifier, NotesViewState>(
  NotesStateNotifier.new,
);

class NotesViewState {
  const NotesViewState({
    this.notes = const [],
    this.query = '',
    this.category,
    this.includeArchived = false,
    this.pinnedOnly = false,
    this.sort = NoteSort.updatedDesc,
  });

  final List<Note> notes;
  final String query;
  final NoteCategory? category;
  final bool includeArchived;
  final bool pinnedOnly;
  final NoteSort sort;

  NotesViewState copyWith({
    List<Note>? notes,
    String? query,
    NoteCategory? category,
    bool clearCategory = false,
    bool? includeArchived,
    bool? pinnedOnly,
    NoteSort? sort,
  }) {
    return NotesViewState(
      notes: notes ?? this.notes,
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      includeArchived: includeArchived ?? this.includeArchived,
      pinnedOnly: pinnedOnly ?? this.pinnedOnly,
      sort: sort ?? this.sort,
    );
  }
}

class NotesStateNotifier extends AsyncNotifier<NotesViewState> {
  NotesRepository? _repository;

  Future<NotesRepository> _getRepository() async {
    return _repository ??= await ref.read(notesRepositoryProvider.future);
  }

  @override
  Future<NotesViewState> build() async {
    final repository = await _getRepository();
    return NotesViewState(notes: await repository.list());
  }

  Future<void> refresh() => _reload();

  Future<void> setQuery(String query) async {
    final current = state.valueOrNull ?? const NotesViewState();
    state = AsyncData(current.copyWith(query: query));
    await _reload();
  }

  Future<void> setCategory(NoteCategory? category) async {
    final current = state.valueOrNull ?? const NotesViewState();
    state = AsyncData(
      current.copyWith(category: category, clearCategory: category == null),
    );
    await _reload();
  }

  Future<void> setPinnedOnly(bool value) async {
    final current = state.valueOrNull ?? const NotesViewState();
    state = AsyncData(current.copyWith(pinnedOnly: value));
    await _reload();
  }

  Future<void> setIncludeArchived(bool value) async {
    final current = state.valueOrNull ?? const NotesViewState();
    state = AsyncData(current.copyWith(includeArchived: value));
    await _reload();
  }

  Future<void> setSort(NoteSort value) async {
    final current = state.valueOrNull ?? const NotesViewState();
    state = AsyncData(current.copyWith(sort: value));
    await _reload();
  }

  Future<Note> create({
    required String title,
    required String content,
    required NoteCategory category,
  }) async {
    final repository = await _getRepository();
    final created = await repository.create(
      title: title,
      content: content,
      category: category,
    );
    await _reload();
    return created;
  }

  Future<void> update(Note note) async {
    final repository = await _getRepository();
    await repository.update(note);
    await _reload();
  }

  Future<void> togglePinned(Note note) async {
    final repository = await _getRepository();
    await repository.setPinned(note.id, !note.isPinned);
    await _reload();
  }

  Future<void> toggleArchived(Note note) async {
    final repository = await _getRepository();
    await repository.setArchived(note.id, !note.isArchived);
    await _reload();
  }

  Future<void> delete(Note note) async {
    final repository = await _getRepository();
    await repository.delete(note.id);
    await _reload();
  }

  Future<void> _reload() async {
    final current = state.valueOrNull ?? const NotesViewState();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = await _getRepository();
      final notes = await repository.list(
        query: current.query,
        category: current.category,
        includeArchived: current.includeArchived,
        pinnedOnly: current.pinnedOnly,
        sort: current.sort,
      );
      return current.copyWith(notes: notes);
    });
  }
}
