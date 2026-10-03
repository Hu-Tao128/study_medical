import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/backend_api.dart';
import '../../../../core/network/backend_api_client.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/progress_radar_model.dart';

/// Sección de progreso por tema con un radar dibujado a mano (sin deps extra).
///
/// Consume `GET /api/v1/progress/radar`; muestra estado de carga, error con
/// reintento y vacío cuando el estudiante todavía no completó sesiones.
class ProgressRadarSection extends StatefulWidget {
  const ProgressRadarSection({super.key});

  @override
  State<ProgressRadarSection> createState() => _ProgressRadarSectionState();
}

class _ProgressRadarSectionState extends State<ProgressRadarSection> {
  bool _loading = true;
  String? _error;
  List<ProgressRadarTopic> _topics = const [];

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
      final topics = await context.read<BackendApi>().getProgressRadar();
      if (!mounted) return;
      setState(() {
        _topics = topics;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.progressByTopicTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                tooltip: l10n.retryButton,
                onPressed: _loading ? null : _load,
                icon: Icon(
                  Icons.refresh,
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: _buildContent(l10n, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, ColorScheme colorScheme) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Column(
        children: [
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: _load, child: Text(l10n.retryButton)),
        ],
      );
    }

    if (_topics.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          l10n.progressEmpty,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    final ranked = [..._topics]
      ..sort((a, b) => b.accuracy.compareTo(a.accuracy));
    final chartTopics = ranked.take(6).toList();

    return Column(
      children: [
        if (chartTopics.length >= 3) ...[
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _RadarChartPainter(
                  values: chartTopics
                      .map((topic) => topic.accuracy.clamp(0.0, 1.0))
                      .toList(growable: false),
                  color: colorScheme.primary,
                  gridColor: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        for (final topic in ranked) _LegendRow(topic: topic),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final ProgressRadarTopic topic;

  const _LegendRow({required this.topic});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = (topic.accuracy * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              topic.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: topic.accuracy.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$percentage%',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color gridColor;

  const _RadarChartPainter({
    required this.values,
    required this.color,
    required this.gridColor,
  });

  static const int _rings = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final count = values.length;
    if (count < 3) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    if (radius <= 0) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    Offset vertex(int index, double r) {
      final angle = -math.pi / 2 + (2 * math.pi * index) / count;
      return center + Offset(math.cos(angle) * r, math.sin(angle) * r);
    }

    for (var ring = 1; ring <= _rings; ring++) {
      final r = radius * ring / _rings;
      final path = Path();
      for (var i = 0; i < count; i++) {
        final point = vertex(i, r);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < count; i++) {
      canvas.drawLine(center, vertex(i, radius), gridPaint);
    }

    final dataPath = Path();
    for (var i = 0; i < count; i++) {
      final point = vertex(i, radius * values[i].clamp(0.0, 1.0));
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        vertex(i, radius * values[i].clamp(0.0, 1.0)),
        3,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.values.length != values.length ||
        !_valuesEqual(oldDelegate.values, values);
  }

  bool _valuesEqual(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
