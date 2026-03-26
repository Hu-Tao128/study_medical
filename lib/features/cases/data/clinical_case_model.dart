class ClinicalCaseModel {
  final String id;
  final String title;
  final String description;
  final List<String> symptoms;
  final String diagnosis;
  final List<CaseQuestion> questions;
  final String topicId;
  final String? difficulty;
  final String visibility;
  final String? groupId;
  final bool aiGenerated;
  final String? aiModel;
  final String? aiSource;
  final String? aiEmbeddingsId;

  const ClinicalCaseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.symptoms,
    required this.diagnosis,
    required this.questions,
    required this.topicId,
    required this.visibility,
    this.difficulty,
    this.groupId,
    this.aiGenerated = false,
    this.aiModel,
    this.aiSource,
    this.aiEmbeddingsId,
  });

  factory ClinicalCaseModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final description = json['description'];
    final diagnosis = json['diagnosis'];
    final topicId = json['topicId'] ?? json['topic_id'];
    final visibility = json['visibility'];

    if (id is! String ||
        title is! String ||
        description is! String ||
        diagnosis is! String ||
        topicId is! String ||
        visibility is! String) {
      throw const FormatException('ClinicalCaseModel: datos inválidos');
    }

    final symptoms =
        (json['symptoms'] as List?)?.whereType<String>().toList(
          growable: false,
        ) ??
        const <String>[];

    final questions =
        (json['questions'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(CaseQuestion.fromJson)
            .toList(growable: false) ??
        const <CaseQuestion>[];

    return ClinicalCaseModel(
      id: id,
      title: title,
      description: description,
      symptoms: symptoms,
      diagnosis: diagnosis,
      questions: questions,
      topicId: topicId,
      visibility: visibility,
      difficulty: json['difficulty'] as String?,
      groupId: json['groupId'] as String? ?? json['group_id'] as String?,
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
}

class CaseQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  const CaseQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory CaseQuestion.fromJson(Map<String, dynamic> json) {
    final question = json['question'];
    final rawCorrectAnswer = json['correctAnswer'] ?? json['correct_answer'];
    if (question is! String) {
      throw const FormatException('CaseQuestion.question inválida');
    }
    int? correctAnswer;
    if (rawCorrectAnswer is int) {
      correctAnswer = rawCorrectAnswer;
    } else if (rawCorrectAnswer is num) {
      correctAnswer = rawCorrectAnswer.toInt();
    }
    if (correctAnswer == null) {
      throw const FormatException('CaseQuestion.correctAnswer inválido');
    }

    final options =
        (json['options'] as List?)?.whereType<String>().toList(
          growable: false,
        ) ??
        const <String>[];

    return CaseQuestion(
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      if (explanation != null) 'explanation': explanation,
    };
  }
}

class CreateCaseRequest {
  final String title;
  final String description;
  final List<String> symptoms;
  final String diagnosis;
  final List<CaseQuestion> questions;
  final String topicId;
  final String difficulty;
  final String visibility;
  final String? groupId;
  final bool aiGenerated;
  final String? aiModel;
  final String? aiSource;
  final String? aiEmbeddingsId;

  const CreateCaseRequest({
    required this.title,
    required this.description,
    required this.symptoms,
    required this.diagnosis,
    required this.questions,
    required this.topicId,
    required this.difficulty,
    required this.visibility,
    this.groupId,
    this.aiGenerated = false,
    this.aiModel,
    this.aiSource,
    this.aiEmbeddingsId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'questions': questions.map((q) => q.toJson()).toList(),
      'topicId': topicId,
      'difficulty': difficulty,
      'visibility': visibility,
      if (groupId != null) 'groupId': groupId,
      'aiGenerated': aiGenerated,
      if (aiModel != null) 'aiModel': aiModel,
      if (aiSource != null) 'aiSource': aiSource,
      if (aiEmbeddingsId != null) 'aiEmbeddingsId': aiEmbeddingsId,
    };
  }
}
