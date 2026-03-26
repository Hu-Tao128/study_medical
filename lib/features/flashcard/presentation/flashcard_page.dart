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
  static const List<Map<String, String>> _topics = [
    {'id': 'general-anatomy', 'label': 'Anatomía'},
    {'id': 'cardiology-basic', 'label': 'Cardiología'},
    {'id': 'neurology-core', 'label': 'Neurología'},
  ];

  late String _selectedTopicId;

  @override
  void initState() {
    super.initState();
    _selectedTopicId = _topics.first['id']!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardProvider>().loadFlashcards(
        topicId: _selectedTopicId,
      );
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
          _buildTopicDropdown(provider),
          IconButton(
            tooltip: l10n.retryButton,
            onPressed: () =>
                provider.loadFlashcards(topicId: provider.currentTopicId),
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

  Widget _buildTopicDropdown(FlashcardProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: DropdownButtonHideUnderline(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButton<String>(
            value: _selectedTopicId,
            icon: const Icon(Icons.arrow_drop_down),
            items: _topics
                .map(
                  (topic) => DropdownMenuItem<String>(
                    value: topic['id'],
                    child: Text(topic['label'] ?? ''),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedTopicId = value);
              provider.loadFlashcards(topicId: value);
            },
          ),
        ),
      ),
    );
  }
}
