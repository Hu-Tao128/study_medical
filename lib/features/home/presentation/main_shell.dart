import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({required this.navigationShell, super.key});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        indicatorColor: colorScheme.primaryContainer,
        onDestinationSelected: _goBranch,
        destinations: [
          NavigationDestination(
            label: l10n.navHome,
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
          ),
          NavigationDestination(
            label: l10n.navStudy,
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school),
          ),
          NavigationDestination(
            label: l10n.navLibrary,
            icon: const Icon(Icons.library_books_outlined),
            selectedIcon: const Icon(Icons.library_books),
          ),
          NavigationDestination(
            label: l10n.navAI,
            icon: const Icon(Icons.smart_toy_outlined),
            selectedIcon: const Icon(Icons.smart_toy),
          ),
          NavigationDestination(
            label: l10n.navProfile,
            icon: const Icon(Icons.person_outlined),
            selectedIcon: const Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
