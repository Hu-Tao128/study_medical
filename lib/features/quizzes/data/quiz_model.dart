class QuizModel {
  final String id;
  final String title;
  final String topicId;
  final List<QuizQuestion> questions;
  final String visibility;
  final String? groupId;
  final bool aiGenerated;
  final String? aiModel;
  final String? aiSource;
  final String? aiEmbeddingsId;

  const QuizModel({
    required this.id,
    required this.title,
    required this.topicId,
    required this.questions,
    required this.visibility,
    this.groupId,
    this.aiGenerated = false,
    this.aiModel,
    this.aiSource,
    this.aiEmbeddingsId,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final topicId = json['topicId'] ?? json['topic_id'];
    final visibility = json['visibility'];
    if (id is! String ||
        title is! String ||
        topicId is! String ||
        visibility is! String) {
      throw const FormatException('QuizModel: datos requeridos faltantes');
    }

    final questionsJson = json['questions'];
    final questions = (questionsJson is List)
        ? questionsJson
              .whereType<Map<String, dynamic>>()
              .map(QuizQuestion.fromJson)
              .toList(growable: false)
        : <QuizQuestion>[];

    return QuizModel(
      id: id,
      title: title,
      topicId: topicId,
      questions: questions,
      visibility: visibility,
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

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final bool aiGenerated;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.aiGenerated = false,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final question = json['question'];
    final rawCorrectAnswer = json['correctAnswer'] ?? json['correct_answer'];
    if (question is! String) {
      throw const FormatException('QuizQuestion.question inválida');
    }
    int? correctAnswer;
    if (rawCorrectAnswer is int) {
      correctAnswer = rawCorrectAnswer;
    } else if (rawCorrectAnswer is num) {
      correctAnswer = rawCorrectAnswer.toInt();
    }
    if (correctAnswer == null) {
      throw const FormatException('QuizQuestion.correctAnswer inválido');
    }
    final options =
        (json['options'] as List?)?.whereType<String>().toList(
          growable: false,
        ) ??
        const <String>[];
    return QuizQuestion(
      question: question,
      options: options,
      correctAnswer: correctAnswer,
      explanation: json['explanation'] as String?,
      aiGenerated:
          json['aiGenerated'] as bool? ??
          (json['ai_generated'] as bool?) ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      if (explanation != null) 'explanation': explanation,
      'aiGenerated': aiGenerated,
    };
  }
}

class CreateQuizRequest {
  final String title;
  final String topicId;
  final List<QuizQuestion> questions;
  final String visibility;
  final String? groupId;
  final bool aiGenerated;
  final String? aiModel;
  final String? aiSource;
  final String? aiEmbeddingsId;

  const CreateQuizRequest({
    required this.title,
    required this.topicId,
    required this.questions,
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
      'topicId': topicId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'visibility': visibility,
      if (groupId != null) 'groupId': groupId,
      'aiGenerated': aiGenerated,
      if (aiModel != null) 'aiModel': aiModel,
      if (aiSource != null) 'aiSource': aiSource,
      if (aiEmbeddingsId != null) 'aiEmbeddingsId': aiEmbeddingsId,
    };
  }
}

class QuizSubmissionRequest {
  final String userId;
  final List<int> answers;

  const QuizSubmissionRequest({required this.userId, required this.answers});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'answers': answers};
  }
}
