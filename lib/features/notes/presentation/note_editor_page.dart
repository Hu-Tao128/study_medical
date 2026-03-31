import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_medical/core/network/backend_api.dart';
import 'package:study_medical/core/network/backend_api_client.dart';
import 'package:study_medical/features/auth/data/auth_service.dart';
import 'package:study_medical/features/notes/data/note_model.dart';

class NoteEditorPage extends StatefulWidget {
  final String? noteId;

  const NoteEditorPage({super.key, this.noteId});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _tagsController;
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  String? _selectedTopicId;
  List<Map<String, String>> _topics = [];
  bool _isFavorite = false;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _tagsController = TextEditingController();
    _quillController = QuillController.basic();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  String _deltaToMarkdown() {
    return _quillController.document.toPlainText().trim();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = context.read<BackendApi>();
      final topics = await api.getTopics();
      if (!mounted) return;
      setState(() => _topics = topics);

      if (widget.noteId != null) {
        final note = await api.getNoteById(widget.noteId!);
        if (!mounted) return;
        _titleController.text = note.title;
        _isFavorite = note.isFavorite;
        _tagsController.text = note.tags.join(', ');

        if (note.contentMd.isNotEmpty) {
          _quillController = QuillController(
            document: Document()..insert(0, note.contentMd),
            selection: const TextSelection.collapsed(offset: 0),
          );
        }

        if (note.topicId != null && _topics.any((t) => t['id'] == note.topicId)) {
          _selectedTopicId = note.topicId;
        }
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is BackendApiException ? error.message : error.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final contentMd = _deltaToMarkdown();

    if (title.isEmpty) {
      setState(() => _error = 'El título no puede estar vacío');
      return;
    }
    if (_quillController.document.isEmpty()) {
      setState(() => _error = 'El contenido no puede estar vacío');
      return;
    }

    final userId = context.read<AuthService>().user?.id;
    if (userId == null || userId.isEmpty) {
      setState(() => _error = 'Usuario no autenticado');
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

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
            contentMd: contentMd,
            topicId: _selectedTopicId,
            tags: tags,
            isFavorite: _isFavorite,
          ),
        );
      } else {
        await api.patchNote(
          widget.noteId!,
          UpdateNoteRequest(
            title: title,
            contentMd: contentMd,
            topicId: _selectedTopicId,
            tags: tags,
            isFavorite: _isFavorite,
          ),
        );
      }

      if (!mounted) return;
      context.pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is BackendApiException ? error.message : error.toString();
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          widget.noteId == null ? 'Nueva nota' : 'Editar nota',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: Icon(
                  _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: _isFavorite ? Colors.amber.shade600 : null,
                ),
              ),
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
            tooltip: 'Marcar como favorita',
          ),
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.check_rounded),
                  onPressed: _saveNote,
                  tooltip: 'Guardar',
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildQuillToolbar(colorScheme),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, 
                                          color: colorScheme.onErrorContainer, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onErrorContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            TextField(
                              controller: _titleController,
                              textCapitalization: TextCapitalization.sentences,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                fontSize: 26,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Título de la nota',
                                border: InputBorder.none,
                                hintStyle: textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.25),
                                  fontWeight: FontWeight.w700,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _MetadataSection(
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              selectedTopicId: _selectedTopicId,
                              topics: _topics,
                              tagsController: _tagsController,
                              onTopicChanged: (v) => setState(() => _selectedTopicId = v),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              height: 1,
                              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Contenido',
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 350,
                              child: QuillEditor(
                                controller: _quillController,
                                focusNode: _editorFocusNode,
                                scrollController: _editorScrollController,
                                config: QuillEditorConfig(
                                  autoFocus: widget.noteId == null,
                                  expands: false,
                                  padding: EdgeInsets.zero,
                                  placeholder: 'Escribe aquí tu nota médica...',
                                  checkBoxReadOnly: false,
                                  customStyles: DefaultStyles(
                                    paragraph: DefaultTextBlockStyle(
                                      textTheme.bodyLarge!.copyWith(
                                        fontSize: 16,
                                        height: 1.7,
                                        color: colorScheme.onSurface,
                                      ),
                                      HorizontalSpacing.zero,
                                      VerticalSpacing.zero,
                                      VerticalSpacing.zero,
                                      null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuillToolbar(ColorScheme colorScheme) {
    return QuillSimpleToolbar(
      controller: _quillController,
      config: QuillSimpleToolbarConfig(
        showBoldButton: true,
        showItalicButton: true,
        showUnderLineButton: true,
        showStrikeThrough: false,
        showInlineCode: true,
        showColorButton: false,
        showBackgroundColorButton: false,
        showClearFormat: true,
        showHeaderStyle: true,
        showListNumbers: true,
        showListBullets: true,
        showListCheck: true,
        showCodeBlock: false,
        showQuote: true,
        showIndent: true,
        showLink: false,
        showUndo: true,
        showRedo: true,
        showFontFamily: false,
        showFontSize: false,
        showAlignmentButtons: false,
        showSearchButton: false,
        showSubscript: true,
        showSuperscript: true,
        customButtons: [
          QuillToolbarCustomButtonOptions(
            icon: const Icon(Icons.table_chart_outlined, size: 20),
            tooltip: 'Insertar tabla',
            onPressed: () => _insertTable(),
          ),
          QuillToolbarCustomButtonOptions(
            icon: const Icon(Icons.image_outlined, size: 20),
            tooltip: 'Insertar imagen',
            onPressed: () => _insertImage(),
          ),
        ],
        buttonOptions: QuillSimpleToolbarButtonOptions(
          base: QuillToolbarBaseButtonOptions(
            iconSize: 20,
            afterButtonPressed: () => _editorFocusNode.requestFocus(),
          ),
        ),
      ),
    );
  }

  void _insertTable() {
    final index = _quillController.selection.baseOffset;
    final length = _quillController.selection.extentOffset - index;
    _quillController.replaceText(
      index,
      length,
      const BlockEmbed('table', '{"rows":3,"columns":2}'),
      null,
    );
  }

  void _insertImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La inserción de imágenes se implementará próximamente'),
        duration: Duration(seconds: 3),
      ),
    );

    // Para implementar imágenes, sigue estos pasos:
    //
    // 1. Agrega image_picker en pubspec.yaml:
    //    image_picker: ^1.0.0
    //
    // 2. Importa el paquete:
    //    import 'package:image_picker/image_picker.dart';
    //
    // 3. Implementa la función:
    //    final picker = ImagePicker();
    //    final file = await picker.pickImage(source: ImageSource.gallery);
    //    if (file != null) {
    //      // Sube la imagen a tu servicio de storage (Firebase Storage, S3, etc.)
    //      // y luego inserta el embed:
    //      final url = await yourStorageService.upload(file);
    //      final index = _quillController.selection.baseOffset;
    //      _quillController.replaceText(
    //        index,
    //        0,
    //        BlockEmbed.image(url),
    //        null,
    //      );
    //    }
  }

  Widget _MetadataSection({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String? selectedTopicId,
    required List<Map<String, String>> topics,
    required TextEditingController tagsController,
    required ValueChanged<String?> onTopicChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedTopicId,
                  decoration: InputDecoration(
                    labelText: 'Tema',
                    labelStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                  ),
                  hint: Text(
                    'Seleccionar tema',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Sin tema'),
                    ),
                    ...topics.map((t) => DropdownMenuItem(
                      value: t['id'],
                      child: Text(t['name'] ?? ''),
                    )),
                  ],
                  onChanged: onTopicChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: tagsController,
                  decoration: InputDecoration(
                    labelText: 'Etiquetas',
                    labelStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    hintText: 'cardiología, diagnóstico...',
                    hintStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    isDense: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 4),
                      child: Icon(
                        Icons.local_offer_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                  style: textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
