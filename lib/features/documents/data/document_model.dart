/// Modelos del RAG por usuario (documentos subidos + consultas con citas).
library;

class UserDocumentModel {
  final String id;
  final String filename;
  final String? contentType;
  final String status;
  final int chunkCount;
  final String? errorMessage;

  const UserDocumentModel({
    required this.id,
    required this.filename,
    this.contentType,
    required this.status,
    this.chunkCount = 0,
    this.errorMessage,
  });

  bool get isReady => status == 'READY';
  bool get isFailed => status == 'FAILED';

  factory UserDocumentModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String) {
      throw FormatException('UserDocumentModel: id inválido ($id)');
    }
    return UserDocumentModel(
      id: id,
      filename: json['filename'] as String? ?? '',
      contentType: json['contentType'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      chunkCount: (json['chunkCount'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

class DocumentCitation {
  final int chunkIndex;
  final int? pageNumber;
  final double similarity;
  final String snippet;

  const DocumentCitation({
    required this.chunkIndex,
    this.pageNumber,
    required this.similarity,
    required this.snippet,
  });

  factory DocumentCitation.fromJson(Map<String, dynamic> json) {
    return DocumentCitation(
      chunkIndex: (json['chunkIndex'] as num?)?.toInt() ?? 0,
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      similarity: (json['similarity'] as num?)?.toDouble() ?? 0.0,
      snippet: json['snippet'] as String? ?? '',
    );
  }
}

class DocumentQueryResult {
  final String answer;
  final List<DocumentCitation> citations;

  const DocumentQueryResult({required this.answer, required this.citations});

  factory DocumentQueryResult.fromJson(Map<String, dynamic> json) {
    final citations =
        (json['citations'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(DocumentCitation.fromJson)
            .toList(growable: false) ??
        const <DocumentCitation>[];
    return DocumentQueryResult(
      answer: json['answer'] as String? ?? '',
      citations: citations,
    );
  }
}
