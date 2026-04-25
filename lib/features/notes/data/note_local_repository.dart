import 'package:hive_flutter/hive_flutter.dart';
import 'package:study_medical/features/notes/data/note_model.dart';

class NoteLocalRepository {
  static const String _boxName = 'notes_local';
  static const String _syncQueueBox = 'notes_sync_queue';
  static const String _idMapBox = 'notes_id_map';

  Box<NoteModel>? _box;
  Box<SyncQueueItem>? _syncQueueBoxInstance;
  Box<NoteIdMapping>? _idMapBoxInstance;

  Future<void> init() async {
    _box = await Hive.openBox<NoteModel>(_boxName);
    _syncQueueBoxInstance = await Hive.openBox<SyncQueueItem>(_syncQueueBox);
    _idMapBoxInstance = await Hive.openBox<NoteIdMapping>(_idMapBox);
  }

  Box<NoteModel> get box {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
        'NoteLocalRepository not initialized. Call init() first.',
      );
    }
    return _box!;
  }

  Box<SyncQueueItem> get syncQueueBox {
    if (_syncQueueBoxInstance == null || !_syncQueueBoxInstance!.isOpen) {
      throw StateError(
        'NoteLocalRepository not initialized. Call init() first.',
      );
    }
    return _syncQueueBoxInstance!;
  }

  Box<NoteIdMapping> get idMapBox {
    if (_idMapBoxInstance == null || !_idMapBoxInstance!.isOpen) {
      throw StateError(
        'NoteLocalRepository not initialized. Call init() first.',
      );
    }
    return _idMapBoxInstance!;
  }

  Future<List<NoteModel>> getAllNotes() async {
    return box.values
        .where((note) => note.syncStatus != SyncStatus.pendingDelete)
        .toList()
      ..sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
        final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
  }

  Future<NoteModel?> getNoteById(String id) async {
    try {
      return box.values.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNote(NoteModel note) async {
    await box.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await box.delete(id);
  }

  Future<void> clearAll() async {
    await box.clear();
  }

  Future<List<SyncQueueItem>> getPendingSyncItems() async {
    return syncQueueBox.values.toList();
  }

  Future<void> addToSyncQueue(SyncQueueItem item) async {
    await syncQueueBox.put(item.id, item);
  }

  Future<void> removeFromSyncQueue(String id) async {
    await syncQueueBox.delete(id);
  }

  Future<void> clearSyncQueue() async {
    await syncQueueBox.clear();
  }

  Future<String?> getRemoteId(String localId) async {
    final mapping = idMapBox.get(localId);
    return mapping?.remoteId;
  }

  Future<void> saveIdMapping(String localId, String remoteId) async {
    await idMapBox.put(
      localId,
      NoteIdMapping(
        localId: localId,
        remoteId: remoteId,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> updatePendingNoteIds(
    String oldLocalId,
    String newRemoteId,
  ) async {
    for (final item in syncQueueBox.values) {
      if (item.noteId == oldLocalId) {
        final updated = item.copyWith(noteId: newRemoteId);
        await syncQueueBox.put(item.id, updated);
      }
    }
  }

  Future<void> clearIdMap() async {
    await idMapBox.clear();
  }
}

class SyncQueueItem {
  final String id;
  final SyncOperation operation;
  final String? noteId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? nextRetryAt;
  final bool inFlight;

  const SyncQueueItem({
    required this.id,
    required this.operation,
    this.noteId,
    this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.nextRetryAt,
    this.inFlight = false,
  });

  SyncQueueItem copyWith({
    String? id,
    SyncOperation? operation,
    String? noteId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
    DateTime? nextRetryAt,
    bool? inFlight,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      noteId: noteId ?? this.noteId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      inFlight: inFlight ?? this.inFlight,
    );
  }
}

enum SyncOperation { create, update, delete }

class NoteIdMapping {
  final String localId;
  final String remoteId;
  final DateTime createdAt;

  const NoteIdMapping({
    required this.localId,
    required this.remoteId,
    required this.createdAt,
  });
}
