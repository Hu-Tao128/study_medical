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

  FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
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

    return FlashcardModel(id: id, question: question, answer: answer);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'question': question, 'answer': answer};
  }
}
