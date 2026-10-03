import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/backend_api.dart';
import '../../../../core/network/backend_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../data/study_session_model.dart';

/// Sesión de repaso: muestra cada tarjeta, permite voltearla y calificarla
/// con un rating 1-5 (SM-2). Al terminar envía los intentos al backend.
class FlashcardSessionPage extends StatefulWidget {
  final StudySessionLaunch launch;

  const FlashcardSessionPage({super.key, required this.launch});

  @override
  State<FlashcardSessionPage> createState() => _FlashcardSessionPageState();
}

class _FlashcardSessionPageState extends State<FlashcardSessionPage> {
  int _index = 0;
  bool _showAnswer = false;
  bool _submitting = false;
  String? _submitError;
  late DateTime _cardShownAt;
  final List<StudyAttempt> _attempts = [];

  List<StudyCardRef> get _cards => widget.launch.session.cards;

  StudyCardRef get _currentCard => _cards[_index];

  String get _currentAnswer {
    final answer = widget.launch.answers[_currentCard.cardId];
    return answer ?? '';
  }

  @override
  void initState() {
    super.initState();
    _cardShownAt = DateTime.now();
  }

  void _revealAnswer() {
    if (_showAnswer) return;
    setState(() => _showAnswer = true);
  }

  Future<void> _rate(int rating) async {
    if (_submitting || _submitError != null) return;

    final elapsedMs = DateTime.now().difference(_cardShownAt).inMilliseconds;
    _attempts.add(
      StudyAttempt(
        cardId: _currentCard.cardId,
        difficulty: rating,
        correct: rating >= 3,
        timeMs: elapsedMs < 0 ? 0 : elapsedMs,
      ),
    );

    if (_index + 1 < _cards.length) {
      setState(() {
        _index += 1;
        _showAnswer = false;
        _cardShownAt = DateTime.now();
      });
      return;
    }

    await _submit();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final api = context.read<BackendApi>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      final result = await api.submitStudySession(
        sessionId: widget.launch.session.sessionId,
        topicId: widget.launch.topicId,
        attempts: _attempts,
      );
      if (!mounted) return;
      context.pushReplacement('/study/flashcards/result', extra: result);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError = error is BackendApiException
            ? error.message
            : l10n.sessionSubmitFailed;
      });
      messenger.showSnackBar(SnackBar(content: Text(l10n.sessionSubmitFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.flashcardSessionTitle)),
        body: Center(child: Text(l10n.noFlashcardsInTopic)),
      );
    }

    final total = _cards.length;
    final progress = (_index + (_showAnswer ? 1 : 0)) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.flashcardSessionTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                l10n.sessionProgress('${_index + 1}', '$total'),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _revealAnswer,
                  child: _FlipCard(
                    showAnswer: _showAnswer,
                    question: _currentCard.question,
                    answer: _currentAnswer.isEmpty
                        ? l10n.answerUnavailable
                        : _currentAnswer,
                    questionLabel: l10n.flashcardsTitle,
                    answerLabel: l10n.answerLabel,
                    tapHint: l10n.tapToReveal,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFooter(l10n, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n, ColorScheme colorScheme) {
    if (_submitting) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: CircularProgressIndicator(),
      );
    }

    if (_submitError != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _submitError!,
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.error),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retryButton),
          ),
        ],
      );
    }

    if (!_showAnswer) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          l10n.tapToReveal,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    final ratings = <_RatingSpec>[
      _RatingSpec(1, l10n.ratingAgain, const Color(0xFFE53935)),
      _RatingSpec(2, l10n.ratingHard, const Color(0xFFFB8C00)),
      _RatingSpec(3, l10n.ratingGood, const Color(0xFFFDD835)),
      _RatingSpec(4, l10n.ratingEasy, const Color(0xFF7CB342)),
      _RatingSpec(5, l10n.ratingPerfect, const Color(0xFF43A047)),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.rateYourRecall,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final spec in ratings)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _RatingButton(
                    spec: spec,
                    onTap: () => _rate(spec.rating),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RatingSpec {
  final int rating;
  final String label;
  final Color color;

  const _RatingSpec(this.rating, this.label, this.color);
}

class _RatingButton extends StatelessWidget {
  final _RatingSpec spec;
  final VoidCallback onTap;

  const _RatingButton({required this.spec, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: spec.color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            children: [
              Text(
                '${spec.rating}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: spec.color,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  spec.label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta con animación de volteo 3D entre pregunta y respuesta.
class _FlipCard extends StatelessWidget {
  final bool showAnswer;
  final String question;
  final String answer;
  final String questionLabel;
  final String answerLabel;
  final String tapHint;

  const _FlipCard({
    required this.showAnswer,
    required this.question,
    required this.answer,
    required this.questionLabel,
    required this.answerLabel,
    required this.tapHint,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          final rotate = Tween<double>(
            begin: math.pi,
            end: 0,
          ).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final angle = rotate.value;
              final isBack = angle > math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: isBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: child,
                      )
                    : child,
              );
            },
          );
        },
        child: showAnswer
            ? _CardFace(
                key: const ValueKey('answer'),
                label: answerLabel,
                text: answer,
                labelColor: Colors.green,
                hint: tapHint,
                colorScheme: colorScheme,
              )
            : _CardFace(
                key: const ValueKey('question'),
                label: questionLabel,
                text: question,
                labelColor: colorScheme.primary,
                hint: tapHint,
                colorScheme: colorScheme,
              ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final String label;
  final String text;
  final Color labelColor;
  final String hint;
  final ColorScheme colorScheme;

  const _CardFace({
    super.key,
    required this.label,
    required this.text,
    required this.labelColor,
    required this.hint,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
