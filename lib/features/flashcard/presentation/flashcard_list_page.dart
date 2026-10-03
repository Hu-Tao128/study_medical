import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/backend_api.dart';
import '../../../../core/network/backend_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/flashcard_model.dart';

/// Lista las flashcards de un tema con creación, edición y borrado.
class FlashcardListPage extends StatefulWidget {
  final String topicId;
  final String? topicName;

  const FlashcardListPage({super.key, required this.topicId, this.topicName});

  @override
  State<FlashcardListPage> createState() => _FlashcardListPageState();
}

class _FlashcardListPageState extends State<FlashcardListPage> {
  bool _loading = true;
  String? _error;
  List<FlashcardModel> _flashcards = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final flashcards = await context.read<BackendApi>().getFlashcardsByTopic(
        widget.topicId,
      );
      if (!mounted) return;
      setState(() {
        _flashcards = flashcards;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is BackendApiException
            ? error.message
            : error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openForm({String? flashcardId}) async {
    final route = flashcardId == null
        ? '/flashcards/${widget.topicId}/new'
        : '/flashcards/${widget.topicId}/$flashcardId/edit';
    final changed = await context.push<bool>(route);
    if (changed == true) {
      await _load();
    }
  }

  Future<bool> _confirmAndDelete(FlashcardModel card) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteFlashcardTitle),
        content: Text(l10n.deleteFlashcardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return false;

    final api = context.read<BackendApi>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await api.deleteFlashcard(card.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.flashcardDeleted)));
      return true;
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error is BackendApiException
                ? error.message
                : l10n.serverConnectionError,
          ),
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicName ?? l10n.flashcardsTitle),
        actions: [
          IconButton(
            tooltip: l10n.studyTopicButton,
            onPressed: () => context.push(
              '/study/flashcards/setup?topicId=${widget.topicId}',
            ),
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: Text(l10n.newFlashcard),
      ),
      body: SafeArea(child: _buildBody(l10n)),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: Text(l10n.retryButton)),
            ],
          ),
        ),
      );
    }

    if (_flashcards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.style_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(l10n.noFlashcardsYet, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _openForm(),
                child: Text(l10n.createFirstFlashcard),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
      itemCount: _flashcards.length,
      itemBuilder: (context, index) {
        final card = _flashcards[index];
        return Dismissible(
          key: ValueKey(card.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmAndDelete(card),
          onDismissed: (_) {
            setState(() {
              _flashcards = _flashcards
                  .where((item) => item.id != card.id)
                  .toList(growable: false);
            });
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          child: _FlashcardTile(
            card: card,
            onTap: () => _openForm(flashcardId: card.id),
          ),
        );
      },
    );
  }
}

class _FlashcardTile extends StatelessWidget {
  final FlashcardModel card;
  final VoidCallback onTap;

  const _FlashcardTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          card.question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            card.answer,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
