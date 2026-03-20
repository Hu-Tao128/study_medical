import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class TopicSelectorPage extends StatefulWidget {
  const TopicSelectorPage({super.key});

  @override
  State<TopicSelectorPage> createState() => _TopicSelectorPageState();
}

class _TopicSelectorPageState extends State<TopicSelectorPage> {
  int _selectedFilter = 0;

  final List<Map<String, dynamic>> _topics = [
    {
      'name': 'Cardiology',
      'icon': Icons.favorite,
      'color': Colors.red,
      'progress': 80,
      'subtitle': 'Heart & Vascular',
    },
    {
      'name': 'Neurology',
      'icon': Icons.psychology,
      'color': Colors.purple,
      'progress': 45,
      'subtitle': 'Brain & Nervous',
    },
    {
      'name': 'Pediatrics',
      'icon': Icons.child_care,
      'color': Colors.amber,
      'progress': 10,
      'subtitle': 'Child Health',
    },
    {
      'name': 'Anatomy',
      'icon': Icons.accessibility_new,
      'color': Colors.blue,
      'progress': 95,
      'subtitle': 'Human Body',
    },
    {
      'name': 'Pharmacology',
      'icon': Icons.medication,
      'color': Colors.teal,
      'progress': 20,
      'subtitle': 'Drugs & Medicine',
    },
    {
      'name': 'Genetics',
      'icon': Icons.biotech,
      'color': Colors.indigo,
      'progress': 0,
      'subtitle': 'Heredity',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, l10n)),
          SliverToBoxAdapter(child: _buildFilters(colorScheme)),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildTopicCard(context, _topics[index], colorScheme),
                childCount: _topics.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          ),
          Expanded(
            child: Text(
              'Select Topic',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ColorScheme colorScheme) {
    final filters = ['All', 'Recent', 'Mastered'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = index);
              },
              backgroundColor: colorScheme.primaryContainer.withValues(
                alpha: 0.3,
              ),
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    Map<String, dynamic> topic,
    ColorScheme colorScheme,
  ) {
    final topicColor = topic['color'] as Color;
    final progress = topic['progress'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: topicColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(topic['icon'] as IconData, color: topicColor),
          ),
          const SizedBox(height: 12),
          Text(
            topic['name'] as String,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            topic['subtitle'] as String,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$progress% Mastered',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
