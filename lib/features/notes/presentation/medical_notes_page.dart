import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

class MedicalNotesPage extends StatefulWidget {
  const MedicalNotesPage({super.key});

  @override
  State<MedicalNotesPage> createState() => _MedicalNotesPageState();
}

class _MedicalNotesPageState extends State<MedicalNotesPage> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _notes = [
    {
      'title': 'Cardiology - Valvular Diseases',
      'subtitle':
          'Comprehensive guide on mitral regurgitation, aortic stenosis clinical signs and management.',
      'date': 'Oct 24',
      'icon': Icons.favorite,
      'color': Colors.red,
    },
    {
      'title': 'Neurological Examination Basics',
      'subtitle':
          'Cranial nerve testing, motor reflexes, and sensory distribution patterns for quick review.',
      'date': 'Oct 22',
      'icon': Icons.psychology,
      'color': Colors.orange,
    },
    {
      'title': 'Pharmacology - Antibiotics',
      'subtitle':
          'Mechanism of action for Cephalosporins and Penicillins with resistance profiles.',
      'date': 'Oct 20',
      'icon': Icons.medication,
      'color': Colors.green,
    },
    {
      'title': 'Radiology Interpretation: Chest X-Ray',
      'subtitle':
          'ABCDE approach to reading chest radiographs with common pathology examples.',
      'date': 'Oct 18',
      'icon': Icons.radar,
      'color': Colors.purple,
    },
    {
      'title': 'Emergency Medicine Triage',
      'subtitle':
          'Priority scoring and immediate management protocols for acute trauma cases.',
      'date': 'Oct 15',
      'icon': Icons.emergency,
      'color': Colors.redAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, l10n, colorScheme)),
            SliverToBoxAdapter(
              child: _buildSearchBar(context, l10n, colorScheme),
            ),
            SliverToBoxAdapter(child: _buildTabs(context, l10n, colorScheme)),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildNoteCard(context, _notes[index], colorScheme),
                  childCount: _notes.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'ai',
            onPressed: () => context.go('/ai'),
            child: Icon(Icons.psychology, color: colorScheme.primary),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => context.push('/notes/new'),
            child: Icon(Icons.add, color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.medicalNotes,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.auto_fix_high, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.searchNotesHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final tabs = [l10n.allNotes, l10n.recentNotes, l10n.pinnedNotes];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    Map<String, dynamic> note,
    ColorScheme colorScheme,
  ) {
    final noteColor = note['color'] as Color;

    return GestureDetector(
      onTap: () => context.push('/notes/1'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: noteColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(note['icon'] as IconData, color: noteColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note['title'] as String,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        note['date'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note['subtitle'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
