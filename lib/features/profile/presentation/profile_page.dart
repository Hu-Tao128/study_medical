import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/color_seed.dart';
import '../../../core/theme/responsive_sizes.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_service.dart';
import '../../settings/presentation/providers/locale_provider.dart';
import '../../settings/presentation/providers/theme_provider.dart';
import '../presentation/providers/profile_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.profile == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadProfile(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadProfile(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, l10n)),
                  SliverToBoxAdapter(child: _buildProfileSection(context, provider)),
                  SliverToBoxAdapter(child: _buildStatsSection(context)),
                  SliverToBoxAdapter(child: _buildAppearanceSection(context)),
                  SliverToBoxAdapter(child: _buildLanguageSection(context)),
                  SliverToBoxAdapter(child: _buildNotificationsSection(context)),
                  SliverToBoxAdapter(child: _buildSupportSection(context)),
                  SliverToBoxAdapter(child: _buildLogoutButton(context, l10n)),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final padding = ResponsiveSpacing.padding(context);
    final fontSize = ResponsiveFontSizes.headlineSmall(context);
    
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Text(
        l10n.profileTitle,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, ProfileProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = provider.profile;
    final padding = ResponsiveSpacing.lg(context);
    final avatarSize = ResponsiveIconSizes.avatar(context);
    final iconSize = avatarSize * 0.6;
    final cameraIconSize = iconSize * 0.3;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer,
                    image: profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profile.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profile?.photoUrl == null || profile!.photoUrl!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: iconSize,
                          color: colorScheme.primary,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(iconSize * 0.08),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: cameraIconSize,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: padding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.responsiveTitleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ResponsiveSpacing.xs(context)),
                  Text(
                    '${profile?.role ?? 'Medical Student'} • ${profile?.level ?? 'Year 1'}',
                    style: Theme.of(context).textTheme.responsiveBodyMedium(context).copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ResponsiveSpacing.xs(context)),
                  Text(
                    profile?.email ?? '',
                    style: Theme.of(context).textTheme.responsiveBodySmall(context).copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final padding = ResponsiveSpacing.md(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          _StatCard(
            title: l10n.hoursLabel,
            value: '120',
            colorScheme: colorScheme,
          ),
          SizedBox(width: padding * 0.75),
          _StatCard(
            title: l10n.gpaLabel,
            value: '4.8',
            colorScheme: colorScheme,
          ),
          SizedBox(width: padding * 0.75),
          _StatCard(
            title: l10n.coursesLabel,
            value: '15',
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final padding = ResponsiveSpacing.padding(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: padding * 0.5),
            child: Text(
              l10n.appearanceSection,
              style: Theme.of(context).textTheme.responsiveTitleSmall(context).copyWith(
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
                _ThemeModeRow(
                  currentMode: themeProvider.themeMode,
                  onChanged: themeProvider.setThemeMode,
                  colorScheme: colorScheme,
                ),
                Divider(
                  height: 1,
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
                _ColorPaletteRow(
                  currentSeed: themeProvider.colorSeed,
                  onChanged: themeProvider.setColorSeed,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final padding = ResponsiveSpacing.padding(context);
    final iconSize = ResponsiveIconSizes.iconMedium(context);
    final labelSize = ResponsiveFontSizes.labelSmall(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: padding * 0.5),
            child: Text(
              l10n.languageSection,
              style: Theme.of(context).textTheme.responsiveTitleSmall(context).copyWith(
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
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(iconSize * 0.4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.language, color: colorScheme.primary, size: iconSize),
                  ),
                  SizedBox(width: padding),
                  Expanded(
                    child: Text(
                      l10n.languageTitle,
                      style: Theme.of(context).textTheme.responsiveBodyMedium(context),
                    ),
                  ),
                  SegmentedButton<Locale>(
                    segments: [
                      ButtonSegment(
                        value: const Locale('en'),
                        label: Text(
                          l10n.englishLabel,
                          style: TextStyle(fontSize: labelSize),
                        ),
                      ),
                      ButtonSegment(
                        value: const Locale('es'),
                        label: Text(
                          l10n.spanishLabel,
                          style: TextStyle(fontSize: labelSize),
                        ),
                      ),
                    ],
                    selected: {localeProvider.locale},
                    onSelectionChanged: (locales) {
                      localeProvider.setLocale(locales.first);
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final padding = ResponsiveSpacing.padding(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: padding * 0.5),
            child: Text(
              l10n.notificationsSection,
              style: Theme.of(context).textTheme.responsiveTitleSmall(context).copyWith(
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
                _SettingsTile(
                  icon: Icons.notifications,
                  title: l10n.notificationsTitle,
                  subtitle: l10n.notificationsSubtitle,
                  colorScheme: colorScheme,
                  onTap: () {},
                ),
                Divider(
                  height: 1,
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
                _SettingsTile(
                  icon: Icons.track_changes,
                  title: l10n.dailyGoalsTitle,
                  subtitle: l10n.dailyGoalsSubtitle,
                  colorScheme: colorScheme,
                  onTap: () {},
                ),
                Divider(
                  height: 1,
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
                _SettingsTile(
                  icon: Icons.history_edu,
                  title: l10n.reviewAlgorithmTitle,
                  subtitle: l10n.reviewAlgorithmSubtitle,
                  colorScheme: colorScheme,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final padding = ResponsiveSpacing.padding(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: padding * 0.5),
            child: Text(
              l10n.supportSection,
              style: Theme.of(context).textTheme.responsiveTitleSmall(context).copyWith(
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
                _SettingsTile(
                  icon: Icons.help,
                  title: l10n.helpCenterTitle,
                  subtitle: l10n.helpCenterSubtitle,
                  colorScheme: colorScheme,
                  onTap: () {},
                ),
                Divider(
                  height: 1,
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
                _SettingsTile(
                  icon: Icons.info,
                  title: l10n.aboutTitle,
                  subtitle: l10n.aboutSubtitle,
                  colorScheme: colorScheme,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    final padding = ResponsiveSpacing.padding(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.logoutConfirmTitle),
                content: Text(l10n.logoutConfirmMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(l10n.cancelButton),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.read<AuthService>().signOut();
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(l10n.logoutButton),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.logout),
          label: Text(l10n.logoutButton),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red,
            padding: EdgeInsets.symmetric(vertical: padding * 1.25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final ColorScheme colorScheme;

  const _StatCard({
    required this.title,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveSpacing.md(context);
    final headlineSize = ResponsiveFontSizes.headlineSmall(context);
    final bodySize = ResponsiveFontSizes.bodySmall(context);

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: padding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                fontSize: headlineSize,
              ),
            ),
            SizedBox(height: ResponsiveSpacing.xs(context)),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: bodySize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeRow extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;
  final ColorScheme colorScheme;

  const _ThemeModeRow({
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
            child: Icon(Icons.dark_mode, color: colorScheme.primary, size: iconSize + 4),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Text(
              l10n.darkModeLabel,
              style: Theme.of(context).textTheme.responsiveBodyMedium(context),
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

class _ColorPaletteRow extends StatelessWidget {
  final ColorSeed currentSeed;
  final ValueChanged<ColorSeed> onChanged;
  final ColorScheme colorScheme;

  const _ColorPaletteRow({
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
            child: Icon(Icons.palette, color: colorScheme.primary, size: circleSize),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Text(
              l10n.accentColorLabel,
              style: Theme.of(context).textTheme.responsiveBodyMedium(context),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
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
    );
  }
}
