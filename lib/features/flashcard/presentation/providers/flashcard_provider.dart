import 'package:flutter/foundation.dart';
import '../../../../core/network/backend_api.dart';
import '../../../../core/network/backend_api_client.dart';
import '../../data/flashcard_model.dart';
import '../../data/flashcard_repository.dart';

class FlashcardProvider extends ChangeNotifier {
  FlashcardProvider({
    required FlashcardRepository repository,
    required BackendApi backendApi,
    String defaultTopicId = _defaultTopicId,
  }) : _repository = repository,
       _backendApi = backendApi,
       _currentTopicId = defaultTopicId;

  static const String _defaultTopicId = 'general-anatomy';
  final FlashcardRepository _repository;
  final BackendApi _backendApi;

  List<FlashcardModel> _flashcards = [];
  bool _isLoading = false;
  String? _error;
  String _currentTopicId;

  List<FlashcardModel> get flashcards => _flashcards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentTopicId => _currentTopicId;

  Future<void> loadFlashcards({String? topicId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final targetTopicId = topicId ?? _currentTopicId;
      _currentTopicId = targetTopicId;

      _flashcards = await _repository.getCachedFlashcards();
      notifyListeners();

      final remoteFlashcards = await _backendApi.getFlashcardsByTopic(
        targetTopicId,
      );

      await _repository.cacheFlashcards(remoteFlashcards);
      _flashcards = remoteFlashcards;
    } catch (e) {
      if (e is BackendApiException) {
        _error = e.message;
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
