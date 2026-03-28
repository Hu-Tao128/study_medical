import '../../features/cases/data/clinical_case_model.dart';
import '../../features/flashcard/data/flashcard_model.dart';
import '../../features/groups/data/chat_message_model.dart';
import '../../features/notes/data/note_model.dart';
import '../../features/profile/data/user_profile_model.dart';
import '../../features/quizzes/data/quiz_model.dart';
import 'backend_api_client.dart';

class BackendApi {
  BackendApi({required Future<String?> Function() tokenProvider})
    : _client = BackendApiClient(tokenProvider: tokenProvider);

  final BackendApiClient _client;

  Future<UserProfile> syncSession() async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/auth/sync-session',
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(
        message: 'Respuesta vacía al sincronizar sesión',
      );
    }
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v1/profile/me',
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Perfil vacío');
    }
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateProfile(ProfileUpdateRequest request) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/profile/me',
      data: request.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Perfil no actualizado');
    }
    return UserProfile.fromJson(data);
  }

  Future<FlashcardModel> createFlashcard(CreateFlashcardRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/flashcards',
      data: request.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Flashcard no creada');
    }
    return FlashcardModel.fromJson(data);
  }

  Future<List<FlashcardModel>> getFlashcardsByTopic(String topicId) async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/flashcards/topic/$topicId',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(FlashcardModel.fromJson)
        .toList(growable: false);
  }

  Future<QuizModel> createQuiz(CreateQuizRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/quizzes/ai-generate',
      data: request.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Quiz no creado');
    }
    return QuizModel.fromJson(data);
  }

  Future<List<QuizModel>> getQuizzesByTopic(String topicId) async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/quizzes/topic/$topicId',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(QuizModel.fromJson)
        .toList(growable: false);
  }

  Future<void> submitQuiz(String quizId, QuizSubmissionRequest request) async {
    await _client.post<void>(
      '/api/v1/quizzes/$quizId/submit',
      data: request.toJson(),
    );
  }

  Future<ClinicalCaseModel> createClinicalCase(
    CreateCaseRequest request,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/cases',
      data: request.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Caso clínico no creado');
    }
    return ClinicalCaseModel.fromJson(data);
  }

  Future<List<ClinicalCaseModel>> getCasesByTopic(String topicId) async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/cases/topic/$topicId',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(ClinicalCaseModel.fromJson)
        .toList(growable: false);
  }

  Future<NoteModel> createNote(CreateNoteRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/notes',
      data: request.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Nota no creada');
    }
    return NoteModel.fromJson(data);
  }

  Future<NoteModel> updateNote(String noteId, UpdateNoteRequest request) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/api/v1/notes/$noteId',
      data: request.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Nota no actualizada');
    }
    return NoteModel.fromJson(data);
  }

  Future<List<NoteModel>> getNotesByUser(String userId) async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/notes/user/$userId',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(NoteModel.fromJson)
        .toList(growable: false);
  }

  Future<List<NoteModel>> getNotes({String? topicId}) async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/notes',
      queryParameters: topicId == null ? null : {'topicId': topicId},
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(NoteModel.fromJson)
        .toList(growable: false);
  }

  Future<NoteModel> getNoteById(String noteId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v1/notes/$noteId',
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Nota no encontrada');
    }
    return NoteModel.fromJson(data);
  }

  Future<NoteModel> patchNote(String noteId, UpdateNoteRequest request) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/notes/$noteId',
      data: request.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Nota no actualizada');
    }
    return NoteModel.fromJson(data);
  }

  Future<void> deleteNote(String noteId) async {
    await _client.delete<void>('/api/v1/notes/$noteId');
  }

  Future<ChatMessageModel> sendChatMessage(
    String roomId,
    ChatMessageRequest request,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/chat/$roomId/messages',
      data: request.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Mensaje no enviado');
    }
    return ChatMessageModel.fromJson(data);
  }

  Future<List<ChatMessageModel>> getChatHistory(String roomId) async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/chat/$roomId/history',
    );
    final data = response.data;
    if (data == null) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(ChatMessageModel.fromJson)
        .toList(growable: false);
  }

  Future<bool> health() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v1/health',
      requiresAuth: false,
    );
    final data = response.data;
    if (data == null) {
      return false;
    }
    final status = data['status'];
    if (status is String) {
      return status.toLowerCase() == 'ok';
    }
    return true;
  }
}
