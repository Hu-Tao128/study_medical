import 'package:flutter/material.dart';

import '../domain/flashcard_entity.dart';

class FlashcardPage extends StatelessWidget {
  final FlashcardEntity flashcard;
  const FlashcardPage({super.key, required this.flashcard});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flashcard ID: ${flashcard.id}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              'Q: ${flashcard.question}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'A: ${flashcard.answer}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
