import 'package:hive/hive.dart';

part 'flashcard_model.g.dart';

@HiveType(typeId: 0)
class FlashcardModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final String answer;

  @HiveField(3)
  final String? topicId;

  @HiveField(4)
  final String? ownerId;

  @HiveField(5)
  final String? difficulty;

  @HiveField(6)
  final String? visibility;

  @HiveField(7)
  final String? groupId;

  @HiveField(8)
  final List<String> tags;

  @HiveField(9)
  final bool aiGenerated;

  @HiveField(10)
  final String? aiModel;

  @HiveField(11)
  final String? aiSource;

  @HiveField(12)
  final String? aiEmbeddingsId;

  FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
    this.topicId,
    this.ownerId,
    this.difficulty,
    this.visibility,
    this.groupId,
    this.tags = const [],
    this.aiGenerated = false,
    this.aiModel,
    this.aiSource,
    this.aiEmbeddingsId,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final question = json['question'];
    final answer = json['answer'];

    if (id == null || question == null || answer == null) {
      throw FormatException(
        'FlashcardModel: campos requeridos faltantes - id: $id, question: $question, answer: $answer',
      );
    }

    if (id is! String || question is! String || answer is! String) {
      throw FormatException(
        'FlashcardModel: tipos inválidos - id: ${id.runtimeType}, question: ${question.runtimeType}, answer: ${answer.runtimeType}',
      );
    }

    final tags =
        (json['tags'] as List?)?.whereType<String>().toList(growable: false) ??
        const <String>[];

    return FlashcardModel(
      id: id,
      question: question,
      answer: answer,
      topicId: json['topicId'] as String? ?? json['topic_id'] as String?,
      ownerId: json['ownerId'] as String? ?? json['owner_id'] as String?,
      difficulty: json['difficulty'] as String?,
      visibility: json['visibility'] as String?,
      groupId: json['groupId'] as String? ?? json['group_id'] as String?,
      tags: tags,
      aiGenerated:
          json['aiGenerated'] as bool? ??
          (json['ai_generated'] as bool?) ??
          false,
      aiModel: json['aiModel'] as String? ?? json['ai_model'] as String?,
      aiSource: json['aiSource'] as String? ?? json['ai_source'] as String?,
      aiEmbeddingsId:
          json['aiEmbeddingsId'] as String? ??
          json['ai_embeddings_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'topicId': topicId,
      'ownerId': ownerId,
      'difficulty': difficulty,
      'visibility': visibility,
      'groupId': groupId,
      'tags': tags,
      'aiGenerated': aiGenerated,
      'aiModel': aiModel,
      'aiSource': aiSource,
      'aiEmbeddingsId': aiEmbeddingsId,
    }..removeWhere((key, value) => value == null);
  }
}

class CreateFlashcardRequest {
  final String topicId;
  final String question;
  final String answer;
  final String difficulty;
  final String visibility;
  final String? groupId;
  final List<String> tags;
  final bool aiGenerated;
  final String? aiModel;
  final String? aiSource;
  final String? aiEmbeddingsId;

  const CreateFlashcardRequest({
    required this.topicId,
    required this.question,
    required this.answer,
    required this.difficulty,
    required this.visibility,
    this.groupId,
    this.tags = const [],
    this.aiGenerated = false,
    this.aiModel,
    this.aiSource,
    this.aiEmbeddingsId,
  });

  Map<String, dynamic> toJson() {
    return {
      'topicId': topicId,
      'question': question,
      'answer': answer,
      'difficulty': difficulty,
      'visibility': visibility,
      if (groupId != null) 'groupId': groupId,
      'tags': tags,
      'aiGenerated': aiGenerated,
      if (aiModel != null) 'aiModel': aiModel,
      if (aiSource != null) 'aiSource': aiSource,
      if (aiEmbeddingsId != null) 'aiEmbeddingsId': aiEmbeddingsId,
    };
  }
}
