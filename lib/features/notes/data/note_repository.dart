import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:study_medical/core/network/backend_api.dart';
import 'package:study_medical/features/notes/data/note_local_repository.dart';
import 'package:study_medical/features/notes/data/note_model.dart';

class NoteRepository {
  final NoteLocalRepository localRepo;
  final BackendApi backendApi;
  final Connectivity _connectivity = Connectivity();

  NoteRepository({required this.localRepo, required this.backendApi});

  Future<bool> _hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<List<NoteModel>> getAllNotes() async {
    return localRepo.getAllNotes();
  }

  Future<List<NoteModel>> getNotesChangedSince(DateTime since) async {
    if (!await _hasConnection()) {
      return localRepo.getAllNotes();
    }
    try {
      final changedNotes = await backendApi.getNotesChangedSince(
        since.toIso8601String(),
      );
      for (final note in changedNotes) {
        await localRepo.saveNote(note);
      }
      return localRepo.getAllNotes();
    } catch (e) {
      return localRepo.getAllNotes();
    }
  }

  Future<NoteModel?> getNoteById(String id) async {
    return localRepo.getNoteById(id);
  }

  Future<NoteModel> createNote(CreateNoteRequest request) async {
    final tempId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    final note = NoteModel(
      id: tempId,
      userId: request.userId,
      title: request.title,
      contentMd: request.contentMd,
      topicId: request.topicId,
      aiSummary: request.aiSummary,
      aiEmbeddingsId: request.aiEmbeddingsId,
      aiGenerated: request.aiGenerated,
      aiModel: request.aiModel,
      aiSource: request.aiSource,
      tags: request.tags ?? [],
      isFavorite: request.isFavorite ?? false,
      isArchived: request.isArchived ?? false,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pendingCreate,
    );

    await localRepo.saveNote(note);

    final syncItem = SyncQueueItem(
      id: tempId,
      operation: SyncOperation.create,
      noteId: tempId,
      data: request.toJson()..['clientOperationId'] = tempId,
      createdAt: now,
    );
    await localRepo.addToSyncQueue(syncItem);

    if (await _hasConnection()) {
      await _processSyncQueue();
    }

    return note;
  }

  Future<NoteModel> updateNote(String id, UpdateNoteRequest request) async {
    final existing = await localRepo.getNoteById(id);
    if (existing == null) {
      throw Exception('Nota no encontrada');
    }

    final isLocal = id.startsWith('local_');
    final syncStatus = isLocal
        ? SyncStatus.pendingUpdate
        : SyncStatus.pendingUpdate;

    final updated = existing.copyWith(
      title: request.title ?? existing.title,
      contentMd: request.contentMd ?? existing.contentMd,
      topicId: request.topicId ?? existing.topicId,
      aiSummary: request.aiSummary ?? existing.aiSummary,
      aiEmbeddingsId: request.aiEmbeddingsId ?? existing.aiEmbeddingsId,
      aiGenerated: request.aiGenerated ?? existing.aiGenerated,
      aiModel: request.aiModel ?? existing.aiModel,
      aiSource: request.aiSource ?? existing.aiSource,
      tags: request.tags ?? existing.tags,
      isFavorite: request.isFavorite ?? existing.isFavorite,
      isArchived: request.isArchived ?? existing.isArchived,
      updatedAt: DateTime.now(),
      syncStatus: syncStatus,
    );

    await localRepo.saveNote(updated);

    final syncItem = SyncQueueItem(
      id: '${id}_${DateTime.now().millisecondsSinceEpoch}',
      operation: SyncOperation.update,
      noteId: id,
      data: request.toJson(),
      createdAt: DateTime.now(),
    );
    await localRepo.addToSyncQueue(syncItem);

    if (await _hasConnection()) {
      await _processSyncQueue();
    }

    return updated;
  }

  Future<void> deleteNote(String id) async {
    final existing = await localRepo.getNoteById(id);
    if (existing == null) return;

    final isLocal = id.startsWith('local_');

    if (isLocal) {
      await localRepo.deleteNote(id);
      final queue = await localRepo.getPendingSyncItems();
      final item = queue.where((i) => i.noteId == id).firstOrNull;
      if (item != null) {
        await localRepo.removeFromSyncQueue(item.id);
      }
    } else {
      final pendingDelete = existing.copyWith(
        syncStatus: SyncStatus.pendingDelete,
      );
      await localRepo.saveNote(pendingDelete);

      final syncItem = SyncQueueItem(
        id: '${id}_${DateTime.now().millisecondsSinceEpoch}',
        operation: SyncOperation.delete,
        noteId: id,
        data: null,
        createdAt: DateTime.now(),
      );
      await localRepo.addToSyncQueue(syncItem);
    }

    if (await _hasConnection()) {
      await _processSyncQueue();
    }
  }

  Future<void> syncWithServer() async {
    if (!await _hasConnection()) return;
    await _compactQueue();
    await _processSyncQueue();
  }

  Future<void> _compactQueue() async {
    final queue = await localRepo.getPendingSyncItems();
    final Map<String, List<SyncQueueItem>> itemsByNoteId = {};

    for (final item in queue) {
      final noteId = item.noteId ?? item.id;
      if (noteId.startsWith('local_')) {
        itemsByNoteId.putIfAbsent(noteId, () => []).add(item);
      }
    }

    for (final entry in itemsByNoteId.entries) {
      final items = entry.value;
      if (items.length <= 1) continue;

      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final hasDelete = items.any((i) => i.operation == SyncOperation.delete);
      if (hasDelete) {
        for (final item in items) {
          await localRepo.removeFromSyncQueue(item.id);
        }
        continue;
      }

      final hasCreate = items.any((i) => i.operation == SyncOperation.create);
      if (hasCreate) {
        final createItem = items.firstWhere(
          (i) => i.operation == SyncOperation.create,
        );
        final updateItems = items
            .where((i) => i.operation == SyncOperation.update)
            .toList();

        final mergedData = <String, dynamic>{...?createItem.data};
        for (final updateItem in updateItems) {
          mergedData.addAll(updateItem.data ?? {});
        }
        final merged = createItem.copyWith(data: mergedData);
        await localRepo.addToSyncQueue(merged);
        for (final updateItem in updateItems) {
          await localRepo.removeFromSyncQueue(updateItem.id);
        }
      } else {
        final sortedUpdates = items
            .where((i) => i.operation == SyncOperation.update)
            .toList();
        sortedUpdates.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        for (int i = 1; i < sortedUpdates.length; i++) {
          await localRepo.removeFromSyncQueue(sortedUpdates[i].id);
        }
      }
    }
  }

  Future<void> _processSyncQueue() async {
    final now = DateTime.now();
    var queue = await localRepo.getPendingSyncItems();

    final expiredInFlight = queue.where(
      (item) =>
          item.inFlight &&
          item.nextRetryAt != null &&
          item.nextRetryAt!.isBefore(now),
    );
    for (final item in expiredInFlight) {
      final reset = item.copyWith(inFlight: false);
      await localRepo.addToSyncQueue(reset);
    }

    final hasExpiredReset = expiredInFlight.isNotEmpty;
    if (hasExpiredReset) {
      queue = await localRepo.getPendingSyncItems();
    }

    for (final item in queue) {
      if (item.inFlight) continue;
      if (item.nextRetryAt != null && item.nextRetryAt!.isAfter(now)) continue;

      final inFlightItem = item.copyWith(inFlight: true);
      await localRepo.addToSyncQueue(inFlightItem);

      try {
        switch (item.operation) {
          case SyncOperation.create:
            if (item.data != null) {
              final remoteNote = await backendApi.createNote(
                CreateNoteRequest(
                  userId: item.data!['userId'] ?? '',
                  title: item.data!['title'] ?? '',
                  contentMd: item.data!['contentMd'] ?? '',
                  topicId: item.data!['topicId'],
                  aiSummary: item.data!['aiSummary'],
                  aiEmbeddingsId: item.data!['aiEmbeddingsId'],
                  aiGenerated: item.data!['aiGenerated'] ?? false,
                  aiModel: item.data!['aiModel'],
                  aiSource: item.data!['aiSource'],
                  tags: item.data!['tags']?.cast<String>(),
                  isFavorite: item.data!['isFavorite'],
                  isArchived: item.data!['isArchived'],
                  clientOperationId: item.data!['clientOperationId'] ?? item.id,
                ),
              );

              final localNote = await localRepo.getNoteById(item.noteId!);
              if (localNote != null) {
                await localRepo.saveIdMapping(item.noteId!, remoteNote.id);
                await localRepo.updatePendingNoteIds(
                  item.noteId!,
                  remoteNote.id,
                );
                final updated = localNote.copyWith(
                  id: remoteNote.id,
                  syncStatus: SyncStatus.synced,
                );
                await localRepo.deleteNote(item.noteId!);
                await localRepo.saveNote(updated);
              }
            }
            break;

          case SyncOperation.update:
            final noteIdToPatch =
                await localRepo.getRemoteId(item.noteId ?? item.id) ??
                (item.noteId ?? item.id);
            if (item.data != null) {
              await backendApi.patchNote(
                noteIdToPatch,
                UpdateNoteRequest(
                  title: item.data!['title'],
                  contentMd: item.data!['contentMd'],
                  topicId: item.data!['topicId'],
                  aiSummary: item.data!['aiSummary'],
                  aiEmbeddingsId: item.data!['aiEmbeddingsId'],
                  aiGenerated: item.data!['aiGenerated'],
                  aiModel: item.data!['aiModel'],
                  aiSource: item.data!['aiSource'],
                  tags: item.data!['tags']?.cast<String>(),
                  isFavorite: item.data!['isFavorite'],
                  isArchived: item.data!['isArchived'],
                ),
              );

              final localNote = await localRepo.getNoteById(
                item.noteId ?? item.id,
              );
              if (localNote != null) {
                final updated = localNote.copyWith(
                  syncStatus: SyncStatus.synced,
                );
                await localRepo.saveNote(updated);
              }
            }
            break;

          case SyncOperation.delete:
            if (item.noteId != null) {
              await backendApi.deleteNote(item.noteId!);
              await localRepo.deleteNote(item.noteId!);
            }
            break;
        }

        await localRepo.removeFromSyncQueue(item.id);
      } catch (e) {
        final nextRetry = _calculateBackoff(item.retryCount + 1);
        final updatedItem = item.copyWith(
          retryCount: item.retryCount + 1,
          nextRetryAt: nextRetry,
          inFlight: false,
        );
        await localRepo.addToSyncQueue(updatedItem);
      }
    }
  }

  DateTime _calculateBackoff(int retryCount) {
    final baseSeconds = 2 * (1 << retryCount.clamp(0, 10));
    final jitter = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000;
    return DateTime.now().add(
      Duration(seconds: (baseSeconds * (1 + jitter)).toInt()),
    );
  }

  Future<int> getPendingSyncCount() async {
    final queue = await localRepo.getPendingSyncItems();
    return queue.length;
  }
}
