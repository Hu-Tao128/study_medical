import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/backend_api.dart';
import '../../../../core/network/backend_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/study_session_model.dart';

/// Configuración previa a una sesión de estudio.
///
/// Carga los temas reales del backend (IDs UUID), deja elegir cuántas
/// tarjetas repasar e inicia la sesión con `startStudySession`.
class StudySetupPage extends StatefulWidget {
  /// Tema preseleccionado (por ejemplo, al llegar desde la lista de tarjetas).
  final String? initialTopicId;

  const StudySetupPage({super.key, this.initialTopicId});

  @override
  State<StudySetupPage> createState() => _StudySetupPageState();
}

class _StudySetupPageState extends State<StudySetupPage> {
  static const double _minLimit = 10;
  static const double _maxLimit = 50;
  static const int _limitDivisions = 4;

  bool _loadingTopics = true;
  bool _starting = false;
  String? _error;
  List<Map<String, String>> _topics = const [];
  String? _selectedTopicId;
  double _limit = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTopics());
  }

  Future<void> _loadTopics() async {
    setState(() {
      _loadingTopics = true;
      _error = null;
    });

    try {
      final topics = await context.read<BackendApi>().getTopics();
      if (!mounted) return;
      final initial = widget.initialTopicId;
      final hasInitial =
          initial != null && topics.any((topic) => topic['id'] == initial);
      setState(() {
        _topics = topics;
        _selectedTopicId = hasInitial
            ? initial
            : (topics.isEmpty ? null : topics.first['id']);
        _loadingTopics = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is BackendApiException
            ? error.message
            : error.toString();
        _loadingTopics = false;
      });
    }
  }

  void _openManage() {
    final topicId = _selectedTopicId;
    if (topicId == null) return;
    final topicName = _topics.firstWhere(
      (topic) => topic['id'] == topicId,
      orElse: () => const {'id': '', 'name': ''},
    )['name'];
    context.push('/flashcards/$topicId', extra: topicName);
  }

  Future<void> _start() async {
    final topicId = _selectedTopicId;
    if (topicId == null || _starting) return;

    final api = context.read<BackendApi>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final topicName =
        _topics.firstWhere(
          (topic) => topic['id'] == topicId,
          orElse: () => const {'id': '', 'name': ''},
        )['name'] ??
        '';

    setState(() => _starting = true);

    try {
      final session = await api.startStudySession(
        topicId: topicId,
        limit: _limit.round(),
      );

      if (session.cards.isEmpty) {
        if (!mounted) return;
        setState(() => _starting = false);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.noFlashcardsInTopic)),
        );
        return;
      }

      // `start` no devuelve la respuesta: la resolvemos con una sola llamada
      // al listado de tarjetas del tema y un mapa cardId -> answer.
      final flashcards = await api.getFlashcardsByTopic(topicId);
      final answers = <String, String>{
        for (final card in flashcards) card.id: card.answer,
      };

      if (!mounted) return;
      setState(() => _starting = false);
      context.push(
        '/study/flashcards/session',
        extra: StudySessionLaunch(
          session: session,
          answers: answers,
          topicId: topicId,
          topicName: topicName,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _starting = false);
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

  void _showModeComingSoon() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.featureComingSoonMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.studySetupTitle)),
      body: SafeArea(child: _buildBody(l10n)),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loadingTopics) {
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
              FilledButton(
                onPressed: _loadTopics,
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
      );
    }

    if (_topics.isEmpty) {
      return Center(child: Text(l10n.noTopicsAvailable));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.studySetupSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.selectTopicLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildTopicDropdown(),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _selectedTopicId == null ? null : _openManage,
            icon: const Icon(Icons.style_outlined),
            label: Text(l10n.manageFlashcards),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.studyModeLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildModeSelector(l10n),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.cardsPerSessionLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              l10n.cardsCount('${_limit.round()}'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          min: _minLimit,
          max: _maxLimit,
          divisions: _limitDivisions,
          value: _limit,
          label: '${_limit.round()}',
          onChanged: _starting
              ? null
              : (value) => setState(() => _limit = value),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _starting ? null : _start,
          child: _starting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.startStudyButton),
        ),
      ],
    );
  }

  Widget _buildTopicDropdown() {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedTopicId,
            items: _topics
                .map(
                  (topic) => DropdownMenuItem<String>(
                    value: topic['id'],
                    child: Text(topic['name'] ?? ''),
                  ),
                )
                .toList(),
            onChanged: _starting
                ? null
                : (value) => setState(() => _selectedTopicId = value),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(AppLocalizations l10n) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: Text(l10n.modeFlashcards),
          selected: true,
          onSelected: (_) {},
        ),
        ChoiceChip(
          label: Text(l10n.modeQuiz),
          selected: false,
          onSelected: (_) => _showModeComingSoon(),
        ),
        ChoiceChip(
          label: Text(l10n.modeCases),
          selected: false,
          onSelected: (_) => _showModeComingSoon(),
        ),
      ],
    );
  }
}
