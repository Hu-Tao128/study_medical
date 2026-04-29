import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/backend_api.dart';
import '../../../core/network/backend_api_client.dart';
import '../data/medical_search_result.dart';

enum _TerminologyFilter { all, nih, local }

class TerminologySearchPage extends StatefulWidget {
  const TerminologySearchPage({super.key});

  @override
  State<TerminologySearchPage> createState() => _TerminologySearchPageState();
}

class _TerminologySearchPageState extends State<TerminologySearchPage> {
  static const int _previewLimit = 5;
  static const int _fetchLimit = 20;

  late final TextEditingController _queryController;

  _TerminologyFilter _selectedFilter = _TerminologyFilter.all;
  bool _isLoading = false;
  bool _isLoadingMoreNih = false;
  bool _isLoadingMoreLocal = false;
  String? _error;

  bool _showAllNih = false;
  bool _showAllLocal = false;

  int _nihPage = 1;
  int _localPage = 1;
  bool _nihHasMore = false;
  bool _localHasMore = false;

  List<MedicalSearchResult> _nihResults = const <MedicalSearchResult>[];
  List<MedicalSearchResult> _localResults = const <MedicalSearchResult>[];

  // TODO: Persist recent searches with local storage (Hive/SharedPreferences).
  List<String> _recentSearches = <String>[
    'Hypertension',
    'Myocardial Infarction',
  ];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: 'diabetes');
    _runSearch();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  MedicalResultSource? _sourceFromFilter(_TerminologyFilter filter) {
    switch (filter) {
      case _TerminologyFilter.nih:
        return MedicalResultSource.nih;
      case _TerminologyFilter.local:
        return MedicalResultSource.local;
      case _TerminologyFilter.all:
        return null;
    }
  }

  Future<void> _runSearch() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _error = 'Ingresa un termino para buscar.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _showAllNih = false;
      _showAllLocal = false;
    });

    try {
      final response = await context
          .read<BackendApi>()
          .searchMedicalTerminology(
            query: query,
            source: _sourceFromFilter(_selectedFilter),
            limit: _fetchLimit,
            page: 1,
          );

      if (!mounted) return;

      setState(() {
        _nihResults = response.nihResults;
        _localResults = response.localResults;
        _nihPage = response.nihPagination.page;
        _localPage = response.localPagination.page;
        _nihHasMore = response.nihPagination.hasMore;
        _localHasMore = response.localPagination.hasMore;
      });

      _addRecentSearch(query);
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

  void _addRecentSearch(String query) {
    final normalized = query.toLowerCase();
    final deduped = _recentSearches
        .where((item) => item.toLowerCase() != normalized)
        .toList(growable: true);
    deduped.insert(0, query);
    setState(() {
      _recentSearches = deduped.take(5).toList(growable: false);
    });
  }

  Future<void> _onMorePressed(MedicalResultSource source) async {
    final isNih = source == MedicalResultSource.nih;
    final showAll = isNih ? _showAllNih : _showAllLocal;
    final hasMore = isNih ? _nihHasMore : _localHasMore;
    final currentCount = isNih ? _nihResults.length : _localResults.length;

    if (!showAll) {
      setState(() {
        if (isNih) {
          _showAllNih = true;
        } else {
          _showAllLocal = true;
        }
      });
      if (currentCount <= _previewLimit && hasMore) {
        await _loadMore(source);
      }
      return;
    }

    if (hasMore) {
      await _loadMore(source);
      return;
    }

    setState(() {
      if (isNih) {
        _showAllNih = false;
      } else {
        _showAllLocal = false;
      }
    });
  }

  Future<void> _loadMore(MedicalResultSource source) async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    final isNih = source == MedicalResultSource.nih;
    final isLoadingMore = isNih ? _isLoadingMoreNih : _isLoadingMoreLocal;
    final hasMore = isNih ? _nihHasMore : _localHasMore;

    if (isLoadingMore || !hasMore) return;

    setState(() {
      if (isNih) {
        _isLoadingMoreNih = true;
      } else {
        _isLoadingMoreLocal = true;
      }
    });

    try {
      final nextPage = isNih ? _nihPage + 1 : _localPage + 1;
      final response = await context
          .read<BackendApi>()
          .searchMedicalTerminology(
            query: query,
            source: source,
            limit: _fetchLimit,
            page: nextPage,
          );

      if (!mounted) return;

      setState(() {
        if (isNih) {
          _nihResults = <MedicalSearchResult>[
            ..._nihResults,
            ...response.nihResults,
          ];
          _nihPage = response.nihPagination.page;
          _nihHasMore = response.nihPagination.hasMore;
        } else {
          _localResults = <MedicalSearchResult>[
            ..._localResults,
            ...response.localResults,
          ];
          _localPage = response.localPagination.page;
          _localHasMore = response.localPagination.hasMore;
        }
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
          if (isNih) {
            _isLoadingMoreNih = false;
          } else {
            _isLoadingMoreLocal = false;
          }
        });
      }
    }
  }

  String _filterLabel(_TerminologyFilter filter) {
    switch (filter) {
      case _TerminologyFilter.all:
        return 'Todos';
      case _TerminologyFilter.nih:
        return 'NIH';
      case _TerminologyFilter.local:
        return 'Local';
    }
  }

  String _contentTypeLabel(MedicalContentType type) {
    switch (type) {
      case MedicalContentType.article:
        return 'Article';
      case MedicalContentType.definition:
        return 'Definition';
      case MedicalContentType.book:
        return 'Book';
      case MedicalContentType.study:
        return 'Study';
    }
  }

  List<MedicalSearchResult> _visibleResults({
    required List<MedicalSearchResult> items,
    required bool showAll,
  }) {
    if (showAll) return items;
    return items.take(_previewLimit).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 980;
    final showNih = _selectedFilter != _TerminologyFilter.local;
    final showLocal = _selectedFilter != _TerminologyFilter.nih;

    final nihVisible = _visibleResults(
      items: _nihResults,
      showAll: _showAllNih,
    );
    final localVisible = _visibleResults(
      items: _localResults,
      showAll: _showAllLocal,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Terminology Search')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _runSearch,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                'Buscar terminologia medica',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Consulta resultados de NIH y tu base de datos local.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(colorScheme),
              const SizedBox(height: 12),
              _buildRecentSearches(colorScheme),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _TerminologyFilter.values
                    .map((filter) {
                      return ChoiceChip(
                        label: Text(_filterLabel(filter)),
                        selected: _selectedFilter == filter,
                        onSelected: (_) async {
                          if (_selectedFilter == filter) return;
                          setState(() {
                            _selectedFilter = filter;
                          });
                          await _runSearch();
                        },
                      );
                    })
                    .toList(growable: false),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              if (_error != null) const SizedBox(height: 16),
              if (_isLoading && _nihResults.isEmpty && _localResults.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!showNih && _localResults.isEmpty && !_isLoading)
                _buildEmptyState()
              else if (!showLocal && _nihResults.isEmpty && !_isLoading)
                _buildEmptyState()
              else if (_nihResults.isEmpty &&
                  _localResults.isEmpty &&
                  !_isLoading)
                _buildEmptyState()
              else
                isWide && showNih && showLocal
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _ResultsSection(
                              title: 'NIH Results',
                              subtitle: 'National Institutes of Health',
                              icon: Icons.account_balance,
                              iconColor: colorScheme.primary,
                              items: nihVisible,
                              hasAny: _nihResults.isNotEmpty,
                              showAll: _showAllNih,
                              hasMore: _nihHasMore,
                              isLoadingMore: _isLoadingMoreNih,
                              onMorePressed: () =>
                                  _onMorePressed(MedicalResultSource.nih),
                              contentTypeLabel: _contentTypeLabel,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: _ResultsSection(
                              title: 'Local Database',
                              subtitle: 'Contenido local',
                              icon: Icons.storage,
                              iconColor: Colors.orange.shade700,
                              items: localVisible,
                              hasAny: _localResults.isNotEmpty,
                              showAll: _showAllLocal,
                              hasMore: _localHasMore,
                              isLoadingMore: _isLoadingMoreLocal,
                              onMorePressed: () =>
                                  _onMorePressed(MedicalResultSource.local),
                              contentTypeLabel: _contentTypeLabel,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          if (showNih)
                            _ResultsSection(
                              title: 'NIH Results',
                              subtitle: 'National Institutes of Health',
                              icon: Icons.account_balance,
                              iconColor: colorScheme.primary,
                              items: nihVisible,
                              hasAny: _nihResults.isNotEmpty,
                              showAll: _showAllNih,
                              hasMore: _nihHasMore,
                              isLoadingMore: _isLoadingMoreNih,
                              onMorePressed: () =>
                                  _onMorePressed(MedicalResultSource.nih),
                              contentTypeLabel: _contentTypeLabel,
                            ),
                          if (showNih && showLocal) const SizedBox(height: 16),
                          if (showLocal)
                            _ResultsSection(
                              title: 'Local Database',
                              subtitle: 'Contenido local',
                              icon: Icons.storage,
                              iconColor: Colors.orange.shade700,
                              items: localVisible,
                              hasAny: _localResults.isNotEmpty,
                              showAll: _showAllLocal,
                              hasMore: _localHasMore,
                              isLoadingMore: _isLoadingMoreLocal,
                              onMorePressed: () =>
                                  _onMorePressed(MedicalResultSource.local),
                              contentTypeLabel: _contentTypeLabel,
                            ),
                        ],
                      ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _queryController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _runSearch(),
              decoration: const InputDecoration(
                hintText: 'Search terminology...',
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _isLoading ? null : _runSearch,
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(ColorScheme colorScheme) {
    if (_recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _recentSearches
          .map((term) {
            return ActionChip(
              label: Text('Recent: $term'),
              backgroundColor: colorScheme.surfaceContainer,
              onPressed: () {
                _queryController.text = term;
                _runSearch();
              },
            );
          })
          .toList(growable: false),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          'Sin resultados para esta busqueda.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<MedicalSearchResult> items;
  final bool hasAny;
  final bool showAll;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onMorePressed;
  final String Function(MedicalContentType type) contentTypeLabel;

  const _ResultsSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.items,
    required this.hasAny,
    required this.showAll,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onMorePressed,
    required this.contentTypeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shouldShowButton =
        hasAny && (items.length >= 5 || hasMore || showAll);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'No hay resultados en esta fuente.',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            )
          else
            ...items.map(
              (item) => _SearchResultCard(
                item: item,
                contentTypeLabel: contentTypeLabel,
              ),
            ),
          if (shouldShowButton) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: isLoadingMore ? null : onMorePressed,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: isLoadingMore
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_buttonLabel(showAll: showAll, hasMore: hasMore)),
            ),
          ],
        ],
      ),
    );
  }

  String _buttonLabel({required bool showAll, required bool hasMore}) {
    if (!showAll) return 'Ver mas +';
    if (hasMore) return 'Ver mas +';
    return 'Ver menos';
  }
}

class _SearchResultCard extends StatelessWidget {
  final MedicalSearchResult item;
  final String Function(MedicalContentType type) contentTypeLabel;

  const _SearchResultCard({required this.item, required this.contentTypeLabel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sourceLabel = item.source == MedicalResultSource.nih
        ? 'NIH'
        : 'LOCAL';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 64,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      contentTypeLabel(item.contentType).toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sourceLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _metaLine(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _metaLine() {
    final parts = <String>[];

    if (item.authors.isNotEmpty) {
      parts.add(item.authors.take(2).join(', '));
    }
    if (item.publicationDate != null && item.publicationDate!.isNotEmpty) {
      parts.add(item.publicationDate!);
    }
    if (item.bookTitle != null && item.bookTitle!.isNotEmpty) {
      parts.add(item.bookTitle!);
    }
    if (item.edition != null && item.edition!.isNotEmpty) {
      parts.add('Ed. ${item.edition!}');
    }
    if (item.pages != null && item.pages!.isNotEmpty) {
      parts.add('Pgs. ${item.pages!}');
    }
    if (parts.isEmpty) {
      return 'Sin metadatos adicionales';
    }

    return parts.join(' • ');
  }
}
