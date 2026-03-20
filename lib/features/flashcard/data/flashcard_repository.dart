import 'package:hive/hive.dart';
import 'flashcard_model.dart';

class FlashcardRepository {
  static const String _boxName = 'flashcards_box';

  Future<Box<FlashcardModel>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<FlashcardModel>(_boxName);
    }
    return Hive.box<FlashcardModel>(_boxName);
  }

  Future<void> cacheFlashcards(List<FlashcardModel> flashcards) async {
    final box = await _getBox();
    final Map<String, FlashcardModel> flashcardMap = {
      for (var f in flashcards) f.id: f,
    };
    await box.putAll(flashcardMap);
  }

  Future<List<FlashcardModel>> getCachedFlashcards() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> clearCache() async {
    final box = await _getBox();
    await box.clear();
  }
}
