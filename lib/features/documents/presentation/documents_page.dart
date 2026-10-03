import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/backend_api.dart';
import '../../../../core/network/backend_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/document_model.dart';

/// Biblioteca de documentos del usuario (el tab de IA).
///
/// Permite subir un PDF (que se procesa en el backend: texto → chunks →
/// embeddings) y abrir un documento listo para preguntarle con citas.
class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  bool _loading = true;
  bool _uploading = false;
  String? _error;
  List<UserDocumentModel> _documents = const [];

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
      final documents = await context.read<BackendApi>().getDocuments();
      if (!mounted) return;
      setState(() {
        _documents = documents;
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

  Future<void> _pickAndUpload() async {
    final l10n = AppLocalizations.of(context)!;
    final api = context.read<BackendApi>();
    final messenger = ScaffoldMessenger.of(context);

    final selection = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );

    if (selection == null || selection.files.isEmpty) return;

    final file = selection.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.documentReadFailed)));
      return;
    }

    setState(() => _uploading = true);
    try {
      await api.uploadDocument(filename: file.name, bytes: bytes);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.documentUploaded)));
      await _load();
    } catch (error) {
      if (!mounted) return;
      final message = error is BackendApiException
          ? (error.statusCode == 503 ? l10n.aiNotConfigured : error.message)
          : l10n.documentUploadFailed;
      messenger.showSnackBar(SnackBar(content: Text(message)));
      await _load();
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myDocuments),
        actions: [
          IconButton(
            tooltip: l10n.retryButton,
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _pickAndUpload,
        icon: _uploading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.upload_file),
        label: Text(l10n.uploadPdf),
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

    if (_documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                size: 72,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noDocuments,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.uploadPdfHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final document = _documents[index];
        return _DocumentTile(
          document: document,
          statusLabel: _statusLabel(l10n, document),
          onTap: document.isReady
              ? () => context.push(
                  '/documents/${document.id}',
                  extra: document.filename,
                )
              : null,
        );
      },
    );
  }

  String _statusLabel(AppLocalizations l10n, UserDocumentModel document) {
    switch (document.status) {
      case 'READY':
        return l10n.documentReady;
      case 'PROCESSING':
        return l10n.documentProcessing;
      case 'FAILED':
        return document.errorMessage ?? l10n.documentFailed;
      default:
        return l10n.documentPending;
    }
  }
}

class _DocumentTile extends StatelessWidget {
  final UserDocumentModel document;
  final String statusLabel;
  final VoidCallback? onTap;

  const _DocumentTile({
    required this.document,
    required this.statusLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          Icons.picture_as_pdf,
          color: document.isFailed ? colorScheme.error : colorScheme.primary,
        ),
        title: Text(
          document.filename,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          statusLabel,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: document.isFailed ? colorScheme.error : null,
          ),
        ),
        trailing: onTap == null
            ? null
            : Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
      ),
    );
  }
}
