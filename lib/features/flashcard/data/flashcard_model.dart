import '../domain/flashcard_entity.dart';

class FlashcardModel extends FlashcardEntity {
  FlashcardModel({
    required super.id,
    required super.question,
    required super.answer,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'question': question, 'answer': answer};
  }
}
