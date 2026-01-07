class FlashcardEntity {
  final String id;
  final String question;
  final String answer;

  FlashcardEntity({
    required this.id,
    required this.question,
    required this.answer,
  });

  FlashcardEntity copyWith({String? id, String? question, String? answer}) {
    return FlashcardEntity(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
    );
  }
}
