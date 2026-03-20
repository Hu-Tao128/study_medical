import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  int _currentIndex = 0;

  final List<_StudyTab> _tabs = const [
    _StudyTab(icon: Icons.style, labelKey: 'flashcardsTitle'),
    _StudyTab(icon: Icons.quiz, labelKey: 'quizzesTitle'),
    _StudyTab(icon: Icons.medical_services, labelKey: 'casesTitle'),
  ];

  void _onTabSelected(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  String _getLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'flashcardsTitle':
        return l10n.flashcardsTitle;
      case 'quizzesTitle':
        return l10n.quizzesTitle;
      case 'casesTitle':
        return l10n.casesTitle;
      default:
        return key;
    }
  }

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
              child: _build3DModelsSection(context, l10n, colorScheme),
            ),
            SliverToBoxAdapter(child: _buildTabBar(colorScheme, l10n)),
            SliverToBoxAdapter(child: _buildContent(l10n)),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.studyCenter,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.chooseYourLearningMode,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DModelsSection(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recent3DModels,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  l10n.viewAll,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ModelCard(
                  title: l10n.heartAnatomy,
                  subtitle: l10n.cardiologyLabel,
                  icon: Icons.favorite,
                  color: Colors.red,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 12),
                _ModelCard(
                  title: l10n.brainStructure,
                  subtitle: l10n.neurologyLabel,
                  icon: Icons.psychology,
                  color: Colors.purple,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 12),
                _ModelCard(
                  title: l10n.skeletalSystem,
                  subtitle: l10n.anatomyLabel,
                  icon: Icons.accessibility_new,
                  color: Colors.amber,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onTabSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _tabs[index].icon,
                        size: 20,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getLabel(l10n, _tabs[index].labelKey),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    switch (_currentIndex) {
      case 0:
        return _FlashcardsSection(l10n: l10n);
      case 1:
        return _QuizzesSection(l10n: l10n);
      case 2:
        return _CasesSection(l10n: l10n);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StudyTab {
  final IconData icon;
  final String labelKey;

  const _StudyTab({required this.icon, required this.labelKey});
}

class _FlashcardsSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _FlashcardsSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickStart,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _StudyCard(
            icon: Icons.style,
            title: l10n.browseTopics,
            subtitle: l10n.startNewFlashcardSession,
            color: Colors.orange,
            colorScheme: colorScheme,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _StudyCard(
            icon: Icons.replay,
            title: l10n.reviewDue,
            subtitle: l10n.cardsWaitingReview('12'),
            color: Colors.blue,
            colorScheme: colorScheme,
            onTap: () => context.push('/study/flashcards/session'),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.yourProgress,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ProgressCard(
            title: l10n.todayLabel,
            cardsReviewed: 45,
            totalCards: 50,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _ProgressCard(
            title: l10n.thisWeek,
            cardsReviewed: 180,
            totalCards: 200,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _QuizzesSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _QuizzesSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.availableQuizzes,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _QuizCard(
            title: 'Cardiology Basics',
            questions: 15,
            time: '10 min',
            difficulty: l10n.easyLabel,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _QuizCard(
            title: 'Neurology Fundamentals',
            questions: 20,
            time: '15 min',
            difficulty: l10n.mediumLabel,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _QuizCard(
            title: 'Pharmacology Interactions',
            questions: 25,
            time: '20 min',
            difficulty: l10n.hardLabel,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _CasesSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _CasesSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.clinicalCases,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _CaseCard(
            title: l10n.patientWithChestPain,
            specialty: l10n.cardiologyLabel,
            difficulty: l10n.mediumLabel,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _CaseCard(
            title: l10n.acuteNeurologicalDeficit,
            specialty: l10n.neurologyLabel,
            difficulty: l10n.hardLabel,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 8),
          _CaseCard(
            title: l10n.pediatricRespiratoryDistress,
            specialty: 'Pediatrics',
            difficulty: l10n.easyLabel,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _StudyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _StudyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final int cardsReviewed;
  final int totalCards;
  final ColorScheme colorScheme;

  const _ProgressCard({
    required this.title,
    required this.cardsReviewed,
    required this.totalCards,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final progress = cardsReviewed / totalCards;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$cardsReviewed/$totalCards',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final String title;
  final int questions;
  final String time;
  final String difficulty;
  final ColorScheme colorScheme;

  const _QuizCard({
    required this.title,
    required this.questions,
    required this.time,
    required this.difficulty,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.quiz, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoChip(label: l10n.questionsLabel('$questions')),
                    const SizedBox(width: 8),
                    _InfoChip(label: time),
                    const SizedBox(width: 8),
                    _InfoChip(label: difficulty),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l10n.startButton,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final String title;
  final String specialty;
  final String difficulty;
  final ColorScheme colorScheme;

  const _CaseCard({
    required this.title,
    required this.specialty,
    required this.difficulty,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.medical_services, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoChip(label: specialty),
                    const SizedBox(width: 8),
                    _InfoChip(label: difficulty),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final ColorScheme colorScheme;

  const _ModelCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
