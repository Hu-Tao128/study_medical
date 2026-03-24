import 'package:flutter_test/flutter_test.dart';
import 'package:study_medical/features/flashcard/data/flashcard_model.dart';

void main() {
  group('FlashcardModel', () {
    test('should create FlashcardModel with required fields', () {
      final flashcard = FlashcardModel(
        id: '1',
        question: '¿Qué es la homeostasis?',
        answer: 'Mantenimiento del equilibrio interno',
      );

      expect(flashcard.id, '1');
      expect(flashcard.question, '¿Qué es la homeostasis?');
      expect(flashcard.answer, 'Mantenimiento del equilibrio interno');
    });

    test('should convert to JSON correctly', () {
      final flashcard = FlashcardModel(
        id: '1',
        question: '¿Qué es la homeostasis?',
        answer: 'Mantenimiento del equilibrio interno',
      );

      final json = flashcard.toJson();

      expect(json['id'], '1');
      expect(json['question'], '¿Qué es la homeostasis?');
      expect(json['answer'], 'Mantenimiento del equilibrio interno');
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '1',
        'question': '¿Qué es la homeostasis?',
        'answer': 'Mantenimiento del equilibrio interno',
      };

      final flashcard = FlashcardModel.fromJson(json);

      expect(flashcard.id, '1');
      expect(flashcard.question, '¿Qué es la homeostasis?');
      expect(flashcard.answer, 'Mantenimiento del equilibrio interno');
    });

    test('should throw FormatException when id is null', () {
      final json = {'id': null, 'question': 'Question', 'answer': 'Answer'};

      expect(
        () => FlashcardModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException when question is missing', () {
      final json = {'id': '1', 'answer': 'Answer'};

      expect(
        () => FlashcardModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException when answer is missing', () {
      final json = {'id': '1', 'question': 'Question'};

      expect(
        () => FlashcardModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException when id is not a String', () {
      final json = {'id': 123, 'question': 'Question', 'answer': 'Answer'};

      expect(
        () => FlashcardModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException when question is not a String', () {
      final json = {'id': '1', 'question': 123, 'answer': 'Answer'};

      expect(
        () => FlashcardModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw FormatException when answer is not a String', () {
      final json = {'id': '1', 'question': 'Question', 'answer': 123};

      expect(
        () => FlashcardModel.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
