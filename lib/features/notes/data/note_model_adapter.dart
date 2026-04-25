import 'package:hive/hive.dart';
import 'package:study_medical/features/notes/data/note_model.dart';
import 'package:study_medical/features/notes/data/note_local_repository.dart';

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 2;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      contentMd: fields[3] as String,
      topicId: fields[4] as String?,
      aiSummary: fields[5] as String?,
      aiEmbeddingsId: fields[6] as String?,
      aiGenerated: fields[7] as bool,
      aiModel: fields[8] as String?,
      aiSource: fields[9] as String?,
      tags: (fields[10] as List?)?.cast<String>() ?? [],
      isFavorite: fields[11] as bool,
      isArchived: fields[12] as bool,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
      syncStatus: SyncStatus.values[(fields[15] as int?) ?? 0],
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.contentMd)
      ..writeByte(4)
      ..write(obj.topicId)
      ..writeByte(5)
      ..write(obj.aiSummary)
      ..writeByte(6)
      ..write(obj.aiEmbeddingsId)
      ..writeByte(7)
      ..write(obj.aiGenerated)
      ..writeByte(8)
      ..write(obj.aiModel)
      ..writeByte(9)
      ..write(obj.aiSource)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.isFavorite)
      ..writeByte(12)
      ..write(obj.isArchived)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.syncStatus.index);
  }
}

class SyncQueueItemAdapter extends TypeAdapter<SyncQueueItem> {
  @override
  final int typeId = 3;

  @override
  SyncQueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueItem(
      id: fields[0] as String,
      operation: SyncOperation.values[(fields[1] as int?) ?? 0],
      noteId: fields[2] as String?,
      data: fields[3] as Map<String, dynamic>?,
      createdAt: fields[4] as DateTime,
      retryCount: fields[5] as int? ?? 0,
      nextRetryAt: fields[6] as DateTime?,
      inFlight: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.operation.index)
      ..writeByte(2)
      ..write(obj.noteId)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.retryCount)
      ..writeByte(6)
      ..write(obj.nextRetryAt)
      ..writeByte(7)
      ..write(obj.inFlight);
  }
}

class NoteIdMappingAdapter extends TypeAdapter<NoteIdMapping> {
  @override
  final int typeId = 4;

  @override
  NoteIdMapping read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteIdMapping(
      localId: fields[0] as String,
      remoteId: fields[1] as String,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NoteIdMapping obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.remoteId)
      ..writeByte(2)
      ..write(obj.createdAt);
  }
}
