import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/backend_api.dart';
import '../../../../core/network/backend_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../../profile/presentation/providers/profile_provider.dart';
import '../data/flashcard_model.dart';

/// Formulario para crear o editar una flashcard de un tema.
///
/// `flashcardId` null => modo creación; presente => modo edición.
class FlashcardFormPage extends StatefulWidget {
  final String topicId;
  final String? flashcardId;

  const FlashcardFormPage({super.key, required this.topicId, this.flashcardId});

  bool get isEditing => flashcardId != null && flashcardId!.isNotEmpty;

  @override
  State<FlashcardFormPage> createState() => _FlashcardFormPageState();
}

class _FlashcardFormPageState extends State<FlashcardFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  bool _loadingExisting = false;
  bool _saving = false;
  String? _loadError;
  String _difficulty = 'MEDIUM';
  String _visibility = 'PRIVATE';
  String? _groupId;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      // Evita renderizar el Form (y su Dropdown) antes de tener los datos,
      // para que el valor precargado se aplique correctamente.
      _loadingExisting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.profile == null && !profileProvider.isLoading) {
        profileProvider.loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() {
      _loadingExisting = true;
      _loadError = null;
    });

    try {
      final card = await context.read<BackendApi>().getFlashcardById(
        widget.flashcardId!,
      );
      if (!mounted) return;
      setState(() {
        _questionController.text = card.question;
        _answerController.text = card.answer;
        _difficulty = (card.difficulty ?? 'MEDIUM').toUpperCase();
        _visibility = (card.visibility ?? 'PRIVATE').toUpperCase();
        _groupId = card.groupId;
        _loadingExisting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error is BackendApiException
            ? error.message
            : error.toString();
        _loadingExisting = false;
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context)!;
    final api = context.read<BackendApi>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _saving = true);

    final request = CreateFlashcardRequest(
      topicId: widget.topicId,
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      difficulty: _difficulty,
      visibility: _visibility,
      groupId: _groupId,
    );

    try {
      if (widget.isEditing) {
        await api.updateFlashcard(widget.flashcardId!, request);
      } else {
        await api.createFlashcard(request);
      }
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.flashcardSaved)));
      navigator.pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error is BackendApiException
                ? error.message
                : l10n.serverConnectionError,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final role = context.watch<ProfileProvider>().profile?.role;
    final canSetVisibility = role == 'TEACHER' || role == 'ADMIN';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? l10n.editFlashcard : l10n.newFlashcard),
      ),
      body: SafeArea(child: _buildBody(l10n, canSetVisibility)),
    );
  }

  Widget _buildBody(AppLocalizations l10n, bool canSetVisibility) {
    if (_loadingExisting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadExisting,
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _questionController,
            minLines: 2,
            maxLines: 5,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.questionLabel,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? l10n.fieldRequired
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _answerController,
            minLines: 3,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: l10n.answerLabel,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? l10n.fieldRequired
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _difficulty,
            decoration: InputDecoration(
              labelText: l10n.difficultyLabel,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'EASY', child: Text(l10n.easyLabel)),
              DropdownMenuItem(value: 'MEDIUM', child: Text(l10n.mediumLabel)),
              DropdownMenuItem(value: 'HARD', child: Text(l10n.hardLabel)),
            ],
            onChanged: _saving
                ? null
                : (value) {
                    if (value != null) setState(() => _difficulty = value);
                  },
          ),
          if (canSetVisibility) ...[
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.visibilityLabel,
                border: const OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _visibility,
                  items: [
                    DropdownMenuItem(
                      value: 'PRIVATE',
                      child: Text(l10n.visibilityPrivate),
                    ),
                    DropdownMenuItem(
                      value: 'PUBLIC',
                      child: Text(l10n.visibilityPublic),
                    ),
                    DropdownMenuItem(
                      value: 'GROUP',
                      enabled: false,
                      child: Text(l10n.visibilityGroup),
                    ),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _visibility = value);
                          }
                        },
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.saveButton),
          ),
        ],
      ),
    );
  }
}
