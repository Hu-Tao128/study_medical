class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String contentMd;
  final String? topicId;
  final String? aiSummary;
  final String? aiEmbeddingsId;
  final bool aiGenerated;
  final String? aiModel;
  final String? aiSource;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.contentMd,
    this.topicId,
    this.aiSummary,
    this.aiEmbeddingsId,
    this.aiGenerated = false,
    this.aiModel,
    this.aiSource,
    this.createdAt,
    this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final userId = json['userId'] ?? json['user_id'];
    final title = json['title'];
    final contentMd = json['contentMd'] ?? json['content_md'];
    if (id is! String ||
        userId is! String ||
        title is! String ||
        contentMd is! String) {
      throw const FormatException('NoteModel inválido');
    }

    DateTime? createdAt;
    final rawCreated = json['createdAt'] ?? json['created_at'];
    if (rawCreated is String) {
      createdAt = DateTime.tryParse(rawCreated);
    }
    DateTime? updatedAt;
    final rawUpdated = json['updatedAt'] ?? json['updated_at'];
    if (rawUpdated is String) {
      updatedAt = DateTime.tryParse(rawUpdated);
    }

    return NoteModel(
      id: id,
      userId: userId,
      title: title,
      contentMd: contentMd,
      topicId: json['topicId'] as String? ?? json['topic_id'] as String?,
      aiSummary: json['aiSummary'] as String? ?? json['ai_summary'] as String?,
      aiEmbeddingsId:
          json['aiEmbeddingsId'] as String? ??
          json['ai_embeddings_id'] as String?,
      aiGenerated:
          json['aiGenerated'] as bool? ??
          (json['ai_generated'] as bool?) ??
          false,
      aiModel: json['aiModel'] as String? ?? json['ai_model'] as String?,
      aiSource: json['aiSource'] as String? ?? json['ai_source'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class CreateNoteRequest {
  final String userId;
  final String title;
  final String contentMd;
  final String? topicId;
  final String? aiSummary;
  final String? aiEmbeddingsId;
  final bool aiGenerated;
  final String? aiModel;
  final String? aiSource;

  const CreateNoteRequest({
    required this.userId,
    required this.title,
    required this.contentMd,
    this.topicId,
    this.aiSummary,
    this.aiEmbeddingsId,
    this.aiGenerated = false,
    this.aiModel,
    this.aiSource,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'contentMd': contentMd,
      if (topicId != null) 'topicId': topicId,
      'aiSummary': aiSummary,
      'aiEmbeddingsId': aiEmbeddingsId,
      'aiGenerated': aiGenerated,
      if (aiModel != null) 'aiModel': aiModel,
      if (aiSource != null) 'aiSource': aiSource,
    }..removeWhere((key, value) => value == null);
  }
}

class UpdateNoteRequest {
  final String? title;
  final String? contentMd;
  final String? topicId;
  final String? aiSummary;
  final String? aiEmbeddingsId;
  final bool? aiGenerated;
  final String? aiModel;
  final String? aiSource;

  const UpdateNoteRequest({
    this.title,
    this.contentMd,
    this.topicId,
    this.aiSummary,
    this.aiEmbeddingsId,
    this.aiGenerated,
    this.aiModel,
    this.aiSource,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (contentMd != null) 'contentMd': contentMd,
      if (topicId != null) 'topicId': topicId,
      if (aiSummary != null) 'aiSummary': aiSummary,
      if (aiEmbeddingsId != null) 'aiEmbeddingsId': aiEmbeddingsId,
      if (aiGenerated != null) 'aiGenerated': aiGenerated,
      if (aiModel != null) 'aiModel': aiModel,
      if (aiSource != null) 'aiSource': aiSource,
    };
  }
}
