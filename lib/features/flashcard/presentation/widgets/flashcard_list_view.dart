import 'package:flutter/material.dart';
import '../../data/flashcard_model.dart';
import 'flashcard_card.dart';

class FlashcardListView extends StatelessWidget {
  final List<FlashcardModel> flashcards;

  const FlashcardListView({super.key, required this.flashcards});

  @override
  Widget build(BuildContext context) {
    // FASE 1: Using ListView.builder for efficient lists
    return ListView.builder(
      itemCount: flashcards.length,
      itemBuilder: (context, index) {
        return FlashcardCard(flashcard: flashcards[index]);
      },
    );
  }
}
