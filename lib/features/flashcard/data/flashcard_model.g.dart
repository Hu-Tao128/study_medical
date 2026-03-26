// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashcardModelAdapter extends TypeAdapter<FlashcardModel> {
  @override
  final int typeId = 0;

  @override
  FlashcardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlashcardModel(
      id: fields[0] as String,
      question: fields[1] as String,
      answer: fields[2] as String,
      topicId: fields[3] as String?,
      ownerId: fields[4] as String?,
      difficulty: fields[5] as String?,
      visibility: fields[6] as String?,
      groupId: fields[7] as String?,
      tags: (fields[8] as List).cast<String>(),
      aiGenerated: fields[9] as bool,
      aiModel: fields[10] as String?,
      aiSource: fields[11] as String?,
      aiEmbeddingsId: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.answer)
      ..writeByte(3)
      ..write(obj.topicId)
      ..writeByte(4)
      ..write(obj.ownerId)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.visibility)
      ..writeByte(7)
      ..write(obj.groupId)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.aiGenerated)
      ..writeByte(10)
      ..write(obj.aiModel)
      ..writeByte(11)
      ..write(obj.aiSource)
      ..writeByte(12)
      ..write(obj.aiEmbeddingsId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
