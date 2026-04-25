import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:study_medical/core/network/backend_api.dart';
import 'package:study_medical/features/notes/data/note_local_repository.dart';
import 'package:study_medical/features/notes/data/note_model.dart';
import 'package:study_medical/features/notes/data/note_model_adapter.dart';
import 'package:study_medical/features/notes/data/note_repository.dart';

class _FakeBackendApi extends BackendApi {
  _FakeBackendApi() : super(tokenProvider: () async => 'test-token');

  int createCalls = 0;
  int patchCalls = 0;
  int deleteCalls = 0;
  final List<CreateNoteRequest> createRequests = <CreateNoteRequest>[];

  @override
  Future<NoteModel> createNote(CreateNoteRequest request) async {
    createCalls += 1;
    createRequests.add(request);
    return NoteModel(
      id: 'remote_$createCalls',
      userId: request.userId,
      title: request.title,
      contentMd: request.contentMd,
      topicId: request.topicId,
      aiSummary: request.aiSummary,
      aiEmbeddingsId: request.aiEmbeddingsId,
      aiGenerated: request.aiGenerated,
      aiModel: request.aiModel,
      aiSource: request.aiSource,
      tags: request.tags ?? const <String>[],
      isFavorite: request.isFavorite ?? false,
      isArchived: request.isArchived ?? false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.synced,
    );
  }

  @override
  Future<NoteModel> patchNote(String noteId, UpdateNoteRequest request) async {
    patchCalls += 1;
    return NoteModel(
      id: noteId,
      userId: 'u1',
      title: request.title ?? '',
      contentMd: request.contentMd ?? '',
      tags: request.tags ?? const <String>[],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteNote(String noteId) async {
    deleteCalls += 1;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel connectivityChannel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
  );

  late Directory tempDir;
  late NoteLocalRepository localRepo;
  late NoteRepository noteRepository;
  late _FakeBackendApi fakeBackend;
  late bool isOnline;

  setUp(() async {
    isOnline = false;
    await dotenv.load(
      fileName: '.env',
      isOptional: true,
      mergeWith: <String, String>{'API_BASE_URL': 'http://localhost'},
    );

    TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, (MethodCall call) async {
          if (call.method == 'check' || call.method == 'checkConnectivity') {
            return isOnline ? <String>['wifi'] : <String>['none'];
          }
          return null;
        });

    tempDir = await Directory.systemTemp.createTemp('note_repo_test_');
    Hive.init(tempDir.path);

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(NoteModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SyncQueueItemAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(NoteIdMappingAdapter());
    }

    localRepo = NoteLocalRepository();
    await localRepo.init();

    fakeBackend = _FakeBackendApi();
    noteRepository = NoteRepository(localRepo: localRepo, backendApi: fakeBackend);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding
        .instance
        .defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('compacts create+updates and syncs as single remote create', () async {
    final created = await noteRepository.createNote(
      const CreateNoteRequest(
        userId: 'u1',
        title: 'titulo inicial',
        contentMd: 'contenido inicial',
      ),
    );

    await noteRepository.updateNote(
      created.id,
      const UpdateNoteRequest(title: 'titulo final'),
    );

    await noteRepository.updateNote(
      created.id,
      const UpdateNoteRequest(tags: <String>['cardio', 'resumen']),
    );

    final pendingBeforeSync = await localRepo.getPendingSyncItems();
    expect(pendingBeforeSync.length, 3);

    isOnline = true;
    await noteRepository.syncWithServer();

    expect(fakeBackend.createCalls, 1);
    expect(fakeBackend.patchCalls, 0);

    final sentCreate = fakeBackend.createRequests.single;
    expect(sentCreate.title, 'titulo final');
    expect(sentCreate.tags, <String>['cardio', 'resumen']);
    expect(sentCreate.clientOperationId, isNotNull);
    expect(sentCreate.clientOperationId, isNotEmpty);

    final pendingAfterSync = await localRepo.getPendingSyncItems();
    expect(pendingAfterSync, isEmpty);

    final localNotes = await localRepo.getAllNotes();
    expect(localNotes.length, 1);
    expect(localNotes.single.id, 'remote_1');
    expect(localNotes.single.title, 'titulo final');
    expect(localNotes.single.tags, <String>['cardio', 'resumen']);
    expect(localNotes.single.syncStatus, SyncStatus.synced);
  });

  test('create+delete offline does not call remote on reconnect', () async {
    final created = await noteRepository.createNote(
      const CreateNoteRequest(
        userId: 'u1',
        title: 'temporal',
        contentMd: 'contenido temporal',
      ),
    );

    await noteRepository.deleteNote(created.id);

    final pendingBeforeSync = await localRepo.getPendingSyncItems();
    expect(pendingBeforeSync, isEmpty);
    expect((await localRepo.getAllNotes()), isEmpty);

    isOnline = true;
    await noteRepository.syncWithServer();

    expect(fakeBackend.createCalls, 0);
    expect(fakeBackend.patchCalls, 0);
    expect(fakeBackend.deleteCalls, 0);
    expect((await localRepo.getPendingSyncItems()), isEmpty);
    expect((await localRepo.getAllNotes()), isEmpty);
  });
}
