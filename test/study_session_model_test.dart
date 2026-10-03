import 'package:flutter_test/flutter_test.dart';
import 'package:study_medical/features/flashcard/data/study_session_model.dart';

void main() {
  group('StudySessionResponse', () {
    test('should parse sessionId and cards from JSON', () {
      final json = {
        'sessionId': 'sess-123',
        'cards': [
          {
            'cardId': 'card-1',
            'question': '¿Qué es la homeostasis?',
            'tags': ['fisiologia'],
          },
          {'cardId': 'card-2', 'question': 'Pregunta 2'},
        ],
      };

      final session = StudySessionResponse.fromJson(json);

      expect(session.sessionId, 'sess-123');
      expect(session.cards, hasLength(2));
      expect(session.cards.first.cardId, 'card-1');
      expect(session.cards.first.tags, ['fisiologia']);
      expect(session.cards.last.tags, isEmpty);
    });

    test('should throw FormatException when sessionId is invalid', () {
      expect(
        () => StudySessionResponse.fromJson({'sessionId': null, 'cards': []}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('StudyAttempt', () {
    test('should serialize to the backend contract', () {
      const attempt = StudyAttempt(
        cardId: 'card-1',
        difficulty: 4,
        correct: true,
        timeMs: 1500,
      );

      expect(attempt.toJson(), {
        'cardId': 'card-1',
        'difficulty': 4,
        'correct': true,
        'timeMs': 1500,
      });
    });
  });

  group('StudySessionResult', () {
    test('should parse accuracy, correctCount and total', () {
      final result = StudySessionResult.fromJson({
        'accuracy': 0.75,
        'correctCount': 15,
        'total': 20,
      });

      expect(result.accuracy, 0.75);
      expect(result.correctCount, 15);
      expect(result.total, 20);
    });

    test('should default missing fields to zero', () {
      final result = StudySessionResult.fromJson({});

      expect(result.accuracy, 0.0);
      expect(result.correctCount, 0);
      expect(result.total, 0);
    });
  });
}
