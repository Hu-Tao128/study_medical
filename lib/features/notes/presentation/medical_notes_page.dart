import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_medical/core/network/backend_api.dart';
import 'package:study_medical/core/network/backend_api_client.dart';
import 'package:study_medical/features/notes/data/note_model.dart';

import '../../../l10n/app_localizations.dart';

class MedicalNotesPage extends StatefulWidget {
  const MedicalNotesPage({super.key});

  @override
  State<MedicalNotesPage> createState() => _MedicalNotesPageState();
}

class _MedicalNotesPageState extends State<MedicalNotesPage> {
  List<NoteModel> _notes = const <NoteModel>[];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotes();
    });
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = context.read<BackendApi>();
      final notes = await api.getNotes();
      if (!mounted) return;
      setState(() => _notes = notes);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        if (error is BackendApiException) {
          _error = error.message;
        } else {
          _error = error.toString();
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicalNotes),
        actions: [
          IconButton(
            tooltip: l10n.retryButton,
            onPressed: _loadNotes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(context, colorScheme, l10n),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/notes/new').then((_) => _loadNotes()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    if (_isLoading) {
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
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadNotes,
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
      );
    }

    if (_notes.isEmpty) {
      return Center(child: Text(l10n.comingSoon('Notes')));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final note = _notes[index];
        final date = note.updatedAt ?? note.createdAt;
        final subtitle = note.contentMd.replaceAll('\n', ' ').trim();
        return ListTile(
          tileColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          leading: Icon(Icons.description, color: colorScheme.primary),
          title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            subtitle.isEmpty ? '-' : subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(_formatDate(date)),
          onTap: () =>
              context.push('/notes/${note.id}').then((_) => _loadNotes()),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '--';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$day/$month';
  }
}
