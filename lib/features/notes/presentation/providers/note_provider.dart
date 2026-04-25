import 'package:flutter/foundation.dart';
import 'package:study_medical/features/notes/data/note_model.dart';
import 'package:study_medical/features/notes/data/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;

  List<NoteModel> _allNotes = [];
  List<NoteModel> _filteredNotes = [];
  bool _isLoading = false;
  String? _error;
  int _pendingSyncCount = 0;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  String? _lastSyncError;

  NoteProvider({required NoteRepository repository}) : _repository = repository;

  List<NoteModel> get allNotes => _allNotes;
  List<NoteModel> get filteredNotes => _filteredNotes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pendingSyncCount => _pendingSyncCount;
  bool get hasPendingSync => _pendingSyncCount > 0;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncAt => _lastSyncAt;
  String? get lastSyncError => _lastSyncError;

  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allNotes = await _repository.getAllNotes();
      _allNotes.sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
        final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
      _filteredNotes = _allNotes;
      _pendingSyncCount = await _repository.getPendingSyncCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterNotes(String query, {bool showOnlyFavorites = false}) {
    final q = query.toLowerCase();
    _filteredNotes = _allNotes.where((note) {
      final matchesSearch =
          note.title.toLowerCase().contains(q) ||
          note.contentMd.toLowerCase().contains(q) ||
          note.tags.any((tag) => tag.toLowerCase().contains(q));
      final matchesFavorite = !showOnlyFavorites || note.isFavorite;
      return matchesSearch && matchesFavorite;
    }).toList();
    notifyListeners();
  }

  Future<void> createNote(CreateNoteRequest request) async {
    _error = null;
    try {
      await _repository.createNote(request);
      await loadNotes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateNote(String id, UpdateNoteRequest request) async {
    _error = null;
    try {
      await _repository.updateNote(id, request);
      await loadNotes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    _error = null;
    try {
      await _repository.deleteNote(id);
      await loadNotes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<NoteModel?> getNoteById(String id) async {
    return _repository.getNoteById(id);
  }

  Future<void> syncWithServer() async {
    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      await _repository.syncWithServer();
      _lastSyncAt = DateTime.now();
      await loadNotes();
    } catch (e) {
      _lastSyncError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
