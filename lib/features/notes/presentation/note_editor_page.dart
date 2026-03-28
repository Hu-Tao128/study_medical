import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_medical/core/network/backend_api.dart';
import 'package:study_medical/core/network/backend_api_client.dart';
import 'package:study_medical/features/auth/data/auth_service.dart';
import 'package:study_medical/features/notes/data/note_model.dart';

import '../../../../l10n/app_localizations.dart';

class NoteEditorPage extends StatefulWidget {
  final String? noteId;

  const NoteEditorPage({super.key, this.noteId});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _topicIdController;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _topicIdController = TextEditingController(text: 'general-anatomy');

    if (widget.noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadNote(widget.noteId!);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _topicIdController.dispose();
    super.dispose();
  }

  Future<void> _loadNote(String noteId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = context.read<BackendApi>();
      final note = await api.getNoteById(noteId);
      if (!mounted) return;
      _titleController.text = note.title;
      _contentController.text = note.contentMd;
      _topicIdController.text = note.topicId ?? _topicIdController.text;
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is BackendApiException
            ? error.message
            : error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final topicId = _topicIdController.text.trim();

    if (title.isEmpty || content.isEmpty || topicId.isEmpty) {
      setState(() => _error = 'Completa title, contentMd y topicId');
      return;
    }

    final userId = context.read<AuthService>().user?.id;
    if (userId == null || userId.isEmpty) {
      setState(() => _error = 'Usuario no autenticado');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final api = context.read<BackendApi>();
      if (widget.noteId == null) {
        await api.createNote(
          CreateNoteRequest(
            userId: userId,
            title: title,
            contentMd: content,
            topicId: topicId,
          ),
        );
      } else {
        await api.patchNote(
          widget.noteId!,
          UpdateNoteRequest(title: title, contentMd: content, topicId: topicId),
        );
      }

      if (!mounted) return;
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is BackendApiException
            ? error.message
            : error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.noteTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: InputDecoration(
                      hintText: l10n.noteTitle,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _topicIdController,
                    decoration: const InputDecoration(
                      labelText: 'topicId',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 10,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: l10n.comingSoon('Notes'),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  if (_isSaving) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
    );
  }
}
