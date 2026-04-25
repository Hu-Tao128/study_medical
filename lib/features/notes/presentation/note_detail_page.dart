import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_medical/features/notes/data/note_model.dart';
import 'package:study_medical/features/notes/presentation/providers/note_provider.dart';

import '../../../../l10n/app_localizations.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteId;

  const NoteDetailPage({super.key, required this.noteId});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  NoteModel? _note;
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNote();
    });
  }

  Future<void> _loadNote() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<NoteProvider>();
      final note = await provider.getNoteById(widget.noteId);
      if (!mounted) return;
      setState(() => _note = note);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteNote() async {
    setState(() => _isDeleting = true);
    try {
      await context.read<NoteProvider>().deleteNote(widget.noteId);
      if (!mounted) return;
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
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
        actions: [
          if (_note?.isFavorite ?? false)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.star, color: Colors.amber),
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context
                .push('/notes/${widget.noteId}/edit')
                .then((_) => _loadNote()),
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _deleteNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _note == null
          ? const SizedBox.shrink()
          : Hero(
              tag: 'note_${widget.noteId}',
              child: Material(
                type: MaterialType.transparency,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _note!.title,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                          ),
                          if (_note!.syncStatus != SyncStatus.synced)
                            _SyncStatusBadge(syncStatus: _note!.syncStatus),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(_note!.updatedAt ?? _note!.createdAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          if (_note!.tags.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: _note!.tags
                                    .map(
                                      (tag) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 1,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      MarkdownBody(
                        data: _note!.contentMd,
                        selectable: true,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              h1: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                              h2: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                              h3: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                              p: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    height: 1.7,
                                    color: colorScheme.onSurface,
                                  ),
                              listBullet: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(height: 1.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SyncStatusBadge extends StatelessWidget {
  final SyncStatus syncStatus;

  const _SyncStatusBadge({required this.syncStatus});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (syncStatus) {
      case SyncStatus.pendingCreate:
        backgroundColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange.shade700;
        text = 'Pendiente';
        icon = Icons.cloud_upload_outlined;
        break;
      case SyncStatus.pendingUpdate:
        backgroundColor = Colors.blue.withValues(alpha: 0.15);
        textColor = Colors.blue.shade700;
        text = 'Pendiente';
        icon = Icons.sync;
        break;
      case SyncStatus.pendingDelete:
        backgroundColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red.shade700;
        text = 'Pendiente';
        icon = Icons.delete_outline;
        break;
      case SyncStatus.synced:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
