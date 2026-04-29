enum MedicalResultSource { nih, local }

enum MedicalContentType { article, definition, book, study }

class MedicalSearchResult {
  final String id;
  final String title;
  final String description;
  final MedicalResultSource source;
  final double? relevanceScore;
  final String? url;
  final List<String> authors;
  final String? publicationDate;
  final String? bookTitle;
  final String? edition;
  final String? pages;
  final MedicalContentType contentType;

  const MedicalSearchResult({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    required this.contentType,
    this.relevanceScore,
    this.url,
    this.authors = const <String>[],
    this.publicationDate,
    this.bookTitle,
    this.edition,
    this.pages,
  });

  factory MedicalSearchResult.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final description = json['description'];
    final sourceRaw = json['source'];
    final contentTypeRaw = json['contentType'] ?? json['content_type'];

    if (id is! String ||
        title is! String ||
        description is! String ||
        sourceRaw is! String ||
        contentTypeRaw is! String) {
      throw const FormatException('MedicalSearchResult: datos invalidos');
    }

    return MedicalSearchResult(
      id: id,
      title: title,
      description: description,
      source: _sourceFromRaw(sourceRaw),
      contentType: _contentTypeFromRaw(contentTypeRaw),
      relevanceScore: _toDoubleOrNull(json['relevanceScore'] ?? json['score']),
      url: json['url'] as String?,
      authors:
          (json['authors'] as List?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const <String>[],
      publicationDate:
          json['publicationDate'] as String? ??
          json['publication_date'] as String?,
      bookTitle: json['bookTitle'] as String? ?? json['book_title'] as String?,
      edition: json['edition'] as String?,
      pages: json['pages'] as String?,
    );
  }

  static MedicalResultSource _sourceFromRaw(String value) {
    switch (value.toLowerCase()) {
      case 'nih':
        return MedicalResultSource.nih;
      case 'local':
        return MedicalResultSource.local;
      default:
        return MedicalResultSource.local;
    }
  }

  static MedicalContentType _contentTypeFromRaw(String value) {
    switch (value.toLowerCase()) {
      case 'article':
        return MedicalContentType.article;
      case 'definition':
        return MedicalContentType.definition;
      case 'book':
        return MedicalContentType.book;
      case 'study':
        return MedicalContentType.study;
      default:
        return MedicalContentType.article;
    }
  }

  static double? _toDoubleOrNull(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}

class SourcePagination {
  final int page;
  final bool hasMore;

  const SourcePagination({required this.page, required this.hasMore});

  factory SourcePagination.fromJson(Map<String, dynamic> json) {
    return SourcePagination(
      page: (json['page'] as num?)?.toInt() ?? 1,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  static const SourcePagination fallback = SourcePagination(
    page: 1,
    hasMore: false,
  );
}

class MedicalSearchResponse {
  final String query;
  final List<MedicalResultSource> sources;
  final List<MedicalSearchResult> nihResults;
  final List<MedicalSearchResult> localResults;
  final SourcePagination nihPagination;
  final SourcePagination localPagination;

  const MedicalSearchResponse({
    required this.query,
    required this.sources,
    required this.nihResults,
    required this.localResults,
    required this.nihPagination,
    required this.localPagination,
  });

  static SourcePagination _resolvePagination(
    Map<String, dynamic>? paginationRaw, {
    required String nestedKey,
    required String hasMoreKey,
  }) {
    if (paginationRaw == null) {
      return SourcePagination.fallback;
    }

    final nested = paginationRaw[nestedKey];
    if (nested is Map<String, dynamic>) {
      return SourcePagination.fromJson(nested);
    }

    final page = (paginationRaw['page'] as num?)?.toInt() ?? 1;
    final hasMoreRaw = paginationRaw[hasMoreKey];
    final hasMore = hasMoreRaw is bool ? hasMoreRaw : false;

    return SourcePagination(page: page, hasMore: hasMore);
  }

  factory MedicalSearchResponse.fromJson(Map<String, dynamic> json) {
    final query = json['query'];
    if (query is! String) {
      throw const FormatException('MedicalSearchResponse: query invalida');
    }

    final sourcesRaw = (json['sources'] as List?)?.whereType<String>() ?? [];

    final resultsRaw = json['results'] as Map<String, dynamic>? ?? {};
    final nihRaw = resultsRaw['nih'] as List?;
    final localRaw = resultsRaw['local'] as List?;

    final paginationRaw = json['pagination'] as Map<String, dynamic>?;

    return MedicalSearchResponse(
      query: query,
      sources: sourcesRaw
          .map((source) => source.toLowerCase())
          .map(
            (source) => source == 'nih'
                ? MedicalResultSource.nih
                : MedicalResultSource.local,
          )
          .toList(growable: false),
      nihResults:
          nihRaw
              ?.whereType<Map<String, dynamic>>()
              .map(MedicalSearchResult.fromJson)
              .toList(growable: false) ??
          const <MedicalSearchResult>[],
      localResults:
          localRaw
              ?.whereType<Map<String, dynamic>>()
              .map(MedicalSearchResult.fromJson)
              .toList(growable: false) ??
          const <MedicalSearchResult>[],
      nihPagination: _resolvePagination(
        paginationRaw,
        nestedKey: 'nih',
        hasMoreKey: 'hasMoreNih',
      ),
      localPagination: _resolvePagination(
        paginationRaw,
        nestedKey: 'local',
        hasMoreKey: 'hasMoreLocal',
      ),
    );
  }
}
