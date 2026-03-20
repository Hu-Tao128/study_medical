import 'package:flutter/foundation.dart';
import '../../data/flashcard_model.dart';
import '../../data/flashcard_repository.dart';

class FlashcardProvider extends ChangeNotifier {
  final FlashcardRepository _repository = FlashcardRepository();

  List<FlashcardModel> _flashcards = [];
  bool _isLoading = false;
  String? _error;

  List<FlashcardModel> get flashcards => _flashcards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFlashcards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Try to get from cache (FASE 1: Hive for cache)
      _flashcards = await _repository.getCachedFlashcards();
      notifyListeners();

      // 2. Fetch from "backend" (FASE 1: simulate backend as source of truth)
      // In a real app, this would be a Firebase call.
      await Future.delayed(const Duration(seconds: 1)); // Simulating network

      final remoteFlashcards = [
        FlashcardModel(
          id: '1',
          question: '¿Cuál es el hueso más largo del cuerpo?',
          answer: 'Fémur',
        ),
        FlashcardModel(
          id: '2',
          question: '¿Cuántas cámaras tiene el corazón humano?',
          answer: 'Cuatro',
        ),
        FlashcardModel(
          id: '3',
          question: '¿Qué órgano produce la insulina?',
          answer: 'Páncreas',
        ),
      ];

      // Update cache
      await _repository.cacheFlashcards(remoteFlashcards);
      _flashcards = remoteFlashcards;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
