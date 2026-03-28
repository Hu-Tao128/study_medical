import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/backend_api.dart';
import '../../../core/network/backend_api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../data/quiz_model.dart';

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  late final TextEditingController _topicIdController;
  List<QuizModel> _quizzes = const <QuizModel>[];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _topicIdController = TextEditingController();
  }

  @override
  void dispose() {
    _topicIdController.dispose();
    super.dispose();
  }

  Future<void> _loadQuizzes() async {
    final topicId = _topicIdController.text.trim();
    if (topicId.isEmpty) {
      setState(() {
        _error = 'Ingresa un topicId para consultar quizzes';
        _quizzes = const <QuizModel>[];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final backendApi = context.read<BackendApi>();
      final quizzes = await backendApi.getQuizzesByTopic(topicId);
      if (!mounted) return;
      setState(() {
        _quizzes = quizzes;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is BackendApiException
            ? error.message
            : error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizzesTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _topicIdController,
              decoration: const InputDecoration(
                labelText: 'topicId',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _loadQuizzes(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadQuizzes,
                icon: const Icon(Icons.search),
                label: const Text('Cargar quizzes'),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(_error!, textAlign: TextAlign.center),
                ),
              )
            else if (_quizzes.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Sin resultados. Busca por topicId.'),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _quizzes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final quiz = _quizzes[index];
                    return ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      leading: const Icon(Icons.quiz),
                      title: Text(quiz.title),
                      subtitle: Text(
                        '${quiz.questions.length} preguntas · ${quiz.visibility}',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
