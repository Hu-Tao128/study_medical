/// Modelos del flujo de estudio (Study Loop).
///
/// Reflejan el contrato real del backend:
/// - `POST /api/v1/study-sessions/start` -> [StudySessionResponse]
/// - `POST /api/v1/study-sessions/submit` -> [StudySessionResult]
library;

/// Referencia ligera de una tarjeta devuelta al iniciar una sesión.
///
/// El backend solo envía `cardId`, `question` y `tags`; la respuesta se
/// resuelve aparte con `getFlashcardsByTopic`/`getFlashcardById`.
class StudyCardRef {
  final String cardId;
  final String question;
  final List<String> tags;

  const StudyCardRef({
    required this.cardId,
    required this.question,
    this.tags = const [],
  });

  factory StudyCardRef.fromJson(Map<String, dynamic> json) {
    final cardId = json['cardId'];
    if (cardId is! String) {
      throw FormatException('StudyCardRef: cardId inválido ($cardId)');
    }
    return StudyCardRef(
      cardId: cardId,
      question: json['question'] as String? ?? '',
      tags:
          (json['tags'] as List?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const <String>[],
    );
  }
}

/// Resultado de `POST /api/v1/study-sessions/start`.
class StudySessionResponse {
  final String sessionId;
  final List<StudyCardRef> cards;

  const StudySessionResponse({required this.sessionId, required this.cards});

  factory StudySessionResponse.fromJson(Map<String, dynamic> json) {
    final sessionId = json['sessionId'];
    if (sessionId is! String) {
      throw FormatException(
        'StudySessionResponse: sessionId inválido ($sessionId)',
      );
    }
    final cards =
        (json['cards'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(StudyCardRef.fromJson)
            .toList(growable: false) ??
        const <StudyCardRef>[];
    return StudySessionResponse(sessionId: sessionId, cards: cards);
  }
}

/// Intento individual que se envía al hacer submit de la sesión.
class StudyAttempt {
  final String cardId;

  /// Rating 1-5 (SM-2). `correct` se deriva de `difficulty >= 3`.
  final int difficulty;
  final bool correct;
  final int timeMs;

  const StudyAttempt({
    required this.cardId,
    required this.difficulty,
    required this.correct,
    required this.timeMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'difficulty': difficulty,
      'correct': correct,
      'timeMs': timeMs,
    };
  }
}

/// Resultado de `POST /api/v1/study-sessions/submit`.
class StudySessionResult {
  final double accuracy;
  final int correctCount;
  final int total;

  const StudySessionResult({
    required this.accuracy,
    required this.correctCount,
    required this.total,
  });

  factory StudySessionResult.fromJson(Map<String, dynamic> json) {
    return StudySessionResult(
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Datos necesarios para lanzar la pantalla de sesión desde el setup.
///
/// Se pasan como `extra` de GoRouter para no tener que volver a pedir la
/// sesión ni las respuestas.
class StudySessionLaunch {
  final StudySessionResponse session;
  final Map<String, String> answers;
  final String topicId;
  final String topicName;

  const StudySessionLaunch({
    required this.session,
    required this.answers,
    required this.topicId,
    required this.topicName,
  });
}
