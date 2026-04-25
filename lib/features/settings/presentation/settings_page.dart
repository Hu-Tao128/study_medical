import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/color_seed.dart';
import '../../../core/theme/responsive_sizes.dart';
import '../../../l10n/app_localizations.dart';
import 'providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AppearanceSection(
              themeProvider: themeProvider,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 24),
            _StudyPreferencesSection(colorScheme: colorScheme),
          ],
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  final ThemeProvider themeProvider;
  final ColorScheme colorScheme;

  const _AppearanceSection({
    required this.themeProvider,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.appearanceSection,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              _ThemeModeSelector(
                currentMode: themeProvider.themeMode,
                onChanged: themeProvider.setThemeMode,
                colorScheme: colorScheme,
              ),
              Divider(
                height: 1,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              _ColorPaletteSelector(
                currentSeed: themeProvider.colorSeed,
                onChanged: themeProvider.setColorSeed,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;
  final ColorScheme colorScheme;

  const _ThemeModeSelector({
    required this.currentMode,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final iconSize = ResponsiveIconSizes.iconSmall(context);
    final padding = ResponsiveSpacing.md(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(padding * 0.75),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.dark_mode,
              color: colorScheme.primary,
              size: iconSize + 4,
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Text(
              l10n.darkModeLabel,
              style: Theme.of(context).textTheme.responsiveBodyMedium(context),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode, size: iconSize),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto, size: iconSize),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode, size: iconSize),
              ),
            ],
            selected: {currentMode},
            onSelectionChanged: (modes) => onChanged(modes.first),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorPaletteSelector extends StatelessWidget {
  final ColorSeed currentSeed;
  final ValueChanged<ColorSeed> onChanged;
  final ColorScheme colorScheme;

  const _ColorPaletteSelector({
    required this.currentSeed,
    required this.onChanged,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final circleSize = ResponsiveIconSizes.colorCircle(context);
    final checkSize = ResponsiveIconSizes.checkIcon(context);
    final padding = ResponsiveSpacing.md(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(padding * 0.75),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.palette,
              color: colorScheme.primary,
              size: circleSize,
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Text(
              l10n.accentColorLabel,
              style: Theme.of(context).textTheme.responsiveBodyMedium(context),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Wrap(
            spacing: padding * 0.5,
            children: ColorSeed.values.map((seed) {
              final isSelected = currentSeed == seed;
              return GestureDetector(
                onTap: () => onChanged(seed),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: seed.color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: colorScheme.onSurface, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: seed.color.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: checkSize)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StudyPreferencesSection extends StatelessWidget {
  final ColorScheme colorScheme;

  const _StudyPreferencesSection({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.notificationsSection,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              _PreferenceTile(
                icon: Icons.notifications,
                title: l10n.notificationsTitle,
                subtitle: l10n.notificationsSubtitle,
                colorScheme: colorScheme,
              ),
              Divider(
                height: 1,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              _PreferenceTile(
                icon: Icons.track_changes,
                title: l10n.dailyGoalsTitle,
                subtitle: l10n.dailyGoalsSubtitle,
                colorScheme: colorScheme,
              ),
              Divider(
                height: 1,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              _PreferenceTile(
                icon: Icons.history_edu,
                title: l10n.reviewAlgorithmTitle,
                subtitle: l10n.reviewAlgorithmSubtitle,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: () {},
    );
  }
}
