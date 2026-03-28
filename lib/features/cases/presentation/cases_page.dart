import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/backend_api.dart';
import '../../../core/network/backend_api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../data/clinical_case_model.dart';

class CasesPage extends StatefulWidget {
  const CasesPage({super.key});

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  late final TextEditingController _topicIdController;
  List<ClinicalCaseModel> _cases = const <ClinicalCaseModel>[];
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

  Future<void> _loadCases() async {
    final topicId = _topicIdController.text.trim();
    if (topicId.isEmpty) {
      setState(() {
        _error = 'Ingresa un topicId para consultar casos clinicos';
        _cases = const <ClinicalCaseModel>[];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final backendApi = context.read<BackendApi>();
      final cases = await backendApi.getCasesByTopic(topicId);
      if (!mounted) return;
      setState(() {
        _cases = cases;
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
      appBar: AppBar(title: Text(l10n.casesTitle)),
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
              onSubmitted: (_) => _loadCases(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadCases,
                icon: const Icon(Icons.search),
                label: const Text('Cargar casos'),
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
            else if (_cases.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Sin resultados. Busca por topicId.'),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _cases.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final clinicalCase = _cases[index];
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
                      leading: const Icon(Icons.medical_services),
                      title: Text(clinicalCase.title),
                      subtitle: Text(
                        '${clinicalCase.visibility} · ${clinicalCase.difficulty ?? 'N/A'}',
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
