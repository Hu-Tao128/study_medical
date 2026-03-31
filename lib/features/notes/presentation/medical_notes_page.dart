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
  List<NoteModel> _allNotes = [];
  List<NoteModel> _filteredNotes = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  bool _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _allNotes.where((note) {
        final matchesSearch = note.title.toLowerCase().contains(query) ||
            note.contentMd.toLowerCase().contains(query) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query));
        
        final matchesFavorite = !_showOnlyFavorites || note.isFavorite;
        
        return matchesSearch && matchesFavorite;
      }).toList();
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
      setState(() {
        _allNotes = notes;
        _applyFilters();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is BackendApiException ? error.message : error.toString();
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
            icon: Icon(_showOnlyFavorites ? Icons.star : Icons.star_border,
                 color: _showOnlyFavorites ? Colors.amber : null),
            onPressed: () {
              setState(() => _showOnlyFavorites = !_showOnlyFavorites);
              _applyFilters();
            },
            tooltip: 'Ver favoritas',
          ),
          IconButton(
            tooltip: l10n.retryButton,
            onPressed: _loadNotes,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar en mis notas y etiquetas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(context, colorScheme, l10n),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/notes/new').then((_) => _loadNotes()),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _cleanPreview(String contentMd) {
    return contentMd
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'\*{1,2}'), '')
        .replaceAll(RegExp(r'[-*+]\s'), '')
        .replaceAll(RegExp(r'^\d+\.\s', multiLine: true), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .replaceAll(RegExp(r'`{1,3}[^`]*`{1,3}'), '')
        .replaceAll(RegExp(r'\|[^|\n]+\|'), '')
        .replaceAll('\n', ' ')
        .trim();
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

    if (_allNotes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.note_add_outlined, size: 64, color: colorScheme.primary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('No hay notas creadas', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Presiona + para crear una nueva nota médica', textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    if (_filteredNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No se encontraron resultados', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        final date = note.updatedAt ?? note.createdAt;
        final preview = note.aiSummary ?? _cleanPreview(note.contentMd);
        
        return _NoteCard(
          note: note,
          preview: preview,
          date: date,
          onTap: () => context.push('/notes/${note.id}').then((_) => _loadNotes()),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final String preview;
  final DateTime? date;
  final VoidCallback onTap;

  const _NoteCard({
    required this.note,
    required this.preview,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Hero(
      tag: 'note_${note.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: note.isFavorite 
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: note.isFavorite ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.isFavorite)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Colors.amber.shade600,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        note.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateShort(date),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    preview,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (note.tags.isNotEmpty || note.aiGenerated) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (note.aiGenerated)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary.withValues(alpha: 0.15),
                                colorScheme.secondary.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AI',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...note.tags.take(3).map((tag) => _TagChip(
                        tag: tag,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      )),
                      if (note.tags.length > 3)
                        _TagChip(
                          tag: '+${note.tags.length - 3}',
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          isMuted: true,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateShort(DateTime? date) {
    if (date == null) return '--';
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Hoy';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isMuted;

  const _TagChip({
    required this.tag,
    required this.colorScheme,
    required this.textTheme,
    this.isMuted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMuted 
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : colorScheme.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag.startsWith('#') ? tag : '#$tag',
        style: textTheme.labelSmall?.copyWith(
          color: isMuted 
              ? colorScheme.onSurfaceVariant
              : colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
