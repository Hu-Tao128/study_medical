/// Modelo de una entrada del radar de progreso por tema.
///
/// Refleja `GET /api/v1/progress/radar` -> `{ topics: [{ topicId, name, accuracy }] }`.
class ProgressRadarTopic {
  final String? topicId;
  final String name;

  /// Precisión acumulada del tema en rango `0.0 - 1.0`.
  final double accuracy;

  const ProgressRadarTopic({
    this.topicId,
    required this.name,
    required this.accuracy,
  });

  factory ProgressRadarTopic.fromJson(Map<String, dynamic> json) {
    return ProgressRadarTopic(
      topicId: json['topicId'] as String?,
      name: json['name'] as String? ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
