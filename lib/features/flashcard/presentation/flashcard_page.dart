import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import 'providers/flashcard_provider.dart';
import 'widgets/flashcard_list_view.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardProvider>().loadFlashcards();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.flashcardsTitle),
        actions: [
          IconButton(
            onPressed: () => provider.loadFlashcards(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(provider, l10n),
    );
  }

  Widget _buildBody(FlashcardProvider provider, AppLocalizations l10n) {
    if (provider.isLoading && provider.flashcards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.flashcards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}'),
            ElevatedButton(
              onPressed: () => provider.loadFlashcards(),
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      );
    }

    if (provider.flashcards.isEmpty) {
      return Center(child: Text(l10n.comingSoon('Flashcards')));
    }

    return Column(
      children: [
        if (provider.isLoading) const LinearProgressIndicator(),
        Expanded(child: FlashcardListView(flashcards: provider.flashcards)),
      ],
    );
  }
}
