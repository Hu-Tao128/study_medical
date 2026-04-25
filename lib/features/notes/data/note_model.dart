enum SyncStatus { synced, pendingCreate, pendingUpdate, pendingDelete }

class NotesPageResponse {
  final List<NoteModel> notes;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;
  final DateTime? lastUpdated;
  final String? institutionId;
  final String? groupId;

  const NotesPageResponse({
    required this.notes,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
    this.lastUpdated,
    this.institutionId,
    this.groupId,
  });

  factory NotesPageResponse.fromJson(Map<String, dynamic> json) {
    return NotesPageResponse(
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 20,
      hasMore: json['hasMore'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
      institutionId:
          json['institutionId'] as String? ?? json['institution_id'] as String?,
      groupId: json['groupId'] as String? ?? json['group_id'] as String?,
    );
  }
}

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
  final List<String> tags;
  final bool isFavorite;
  final bool isArchived;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

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
    this.tags = const [],
    this.isFavorite = false,
    this.isArchived = false,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  NoteModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? contentMd,
    String? topicId,
    String? aiSummary,
    String? aiEmbeddingsId,
    bool? aiGenerated,
    String? aiModel,
    String? aiSource,
    List<String>? tags,
    bool? isFavorite,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      contentMd: contentMd ?? this.contentMd,
      topicId: topicId ?? this.topicId,
      aiSummary: aiSummary ?? this.aiSummary,
      aiEmbeddingsId: aiEmbeddingsId ?? this.aiEmbeddingsId,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      aiModel: aiModel ?? this.aiModel,
      aiSource: aiSource ?? this.aiSource,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

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
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      isFavorite:
          json['isFavorite'] as bool? ?? json['is_favorite'] as bool? ?? false,
      isArchived:
          json['isArchived'] as bool? ?? json['is_archived'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'contentMd': contentMd,
      'topicId': topicId,
      'aiSummary': aiSummary,
      'aiEmbeddingsId': aiEmbeddingsId,
      'aiGenerated': aiGenerated,
      'aiModel': aiModel,
      'aiSource': aiSource,
      'tags': tags,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus.name,
    }..removeWhere((key, value) => value == null);
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
  final List<String>? tags;
  final bool? isFavorite;
  final bool? isArchived;
  final String? clientOperationId;

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
    this.tags,
    this.isFavorite,
    this.isArchived,
    this.clientOperationId,
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
      if (clientOperationId != null) 'clientOperationId': clientOperationId,
      if (aiModel != null) 'aiModel': aiModel,
      if (aiSource != null) 'aiSource': aiSource,
      if (tags != null) 'tags': tags,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (isArchived != null) 'isArchived': isArchived,
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
  final List<String>? tags;
  final bool? isFavorite;
  final bool? isArchived;

  const UpdateNoteRequest({
    this.title,
    this.contentMd,
    this.topicId,
    this.aiSummary,
    this.aiEmbeddingsId,
    this.aiGenerated,
    this.aiModel,
    this.aiSource,
    this.tags,
    this.isFavorite,
    this.isArchived,
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
      if (tags != null) 'tags': tags,
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (isArchived != null) 'isArchived': isArchived,
    };
  }
}
