import 'dart:developer' as developer;

import '../../features/cases/data/clinical_case_model.dart';
import '../../features/flashcard/data/flashcard_model.dart';
import '../../features/groups/data/chat_message_model.dart';
import '../../features/notes/data/note_model.dart';
import '../../features/profile/data/user_profile_model.dart';
import '../../features/quizzes/data/quiz_model.dart';
import '../../features/study/data/medical_search_result.dart';
import 'package:dio/dio.dart';
import 'backend_api_client.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;

  AuthResponse({required this.accessToken, required this.refreshToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    final refreshToken = json['refreshToken'];

    if (accessToken == null || refreshToken == null) {
      throw FormatException(
        'AuthResponse: accessToken o refreshToken son null. JSON: $json',
      );
    }

    return AuthResponse(
      accessToken: accessToken as String,
      refreshToken: refreshToken as String,
    );
  }
}

class BackendApi {
  BackendApi({
    required Future<String?> Function() tokenProvider,
    Future<void> Function()? refreshTokens,
  }) : _client = BackendApiClient(
         tokenProvider: tokenProvider,
         refreshTokens: refreshTokens,
       );

  final BackendApiClient _client;

  Future<AuthResponse> syncSession(String firebaseToken) async {
    developer.log(
      'syncSession: sending request to backend',
      name: 'BACKEND_API',
    );
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/auth/sync-session',
      options: Options(headers: {'Authorization': 'Bearer $firebaseToken'}),
    );
    final data = response.data;
    developer.log(
      'syncSession: response received. Data type: ${data.runtimeType}',
      name: 'BACKEND_API',
    );
    if (data == null) {
      throw const BackendApiException(
        message: 'Respuesta vacía al sincronizar sesión',
      );
    }
    if (data is! Map<String, dynamic>) {
      throw FormatException(
        'syncSession: Expected Map<String, dynamic> but got ${data.runtimeType}. Data: $data',
      );
    }
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Error al refrescar token');
    }
    return AuthResponse.fromJson(data);
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

  Future<MedicalSearchResponse> searchMedicalTerminology({
    required String query,
    MedicalResultSource? source,
    int? limit,
    int? page,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v1/search',
      queryParameters: {
        'q': query,
        if (source != null) 'source': source.name,
        if (limit != null) 'limit': limit,
        if (page != null) 'page': page,
      },
    );
    final data = response.data;
    if (data == null) {
      throw const BackendApiException(message: 'Busqueda vacia');
    }
    return MedicalSearchResponse.fromJson(data);
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

  Future<List<NoteModel>> getNotesChangedSince(String sinceIso) async {
    try {
      final response = await _client.get<List<dynamic>>(
        '/api/v1/notes/changed',
        queryParameters: {'since': sinceIso},
      );
      final data = response.data;
      if (data == null) {
        return const [];
      }
      return data
          .whereType<Map<String, dynamic>>()
          .map(NoteModel.fromJson)
          .toList(growable: false);
    } catch (e) {
      return const [];
    }
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
    final response = await _client.get<Map<String, dynamic>>('/api/v1/health');
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

  Future<List<Map<String, String>>> getTopics() async {
    final response = await _client.get<List<dynamic>>('/api/v1/topics');
    final data = response.data;
    if (data == null) return [];
    return data.map((e) {
      final map = e as Map<String, dynamic>;
      return {'id': map['id'] as String, 'name': map['name'] as String};
    }).toList();
  }
}
