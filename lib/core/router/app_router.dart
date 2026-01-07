import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/home/presentation/main_shell.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/flashcard/presentation/flashcard_page.dart';
import '../../features/flashcard/domain/flashcard_entity.dart';
import '../../features/cases/presentation/cases_page.dart';
import '../../features/quizzes/presentation/quizzes_page.dart';
import '../../features/settings/presentation/settings_page.dart';

// No local navigator keys here if we pass them or use contextless navigation cautiously,
// but GoRouter usually needs them or handles them. We'll reuse the globals logic if needed,
// but for cleaner arch, let's keep it simple.

GoRouter appRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: authService,
    redirect: (context, state) {
      final bool isLoggedIn = authService.isAuthenticated;
      final bool isLoggingIn = state.uri.path == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/flashcards',
                builder: (context, state) => FlashcardPage(
                  // Temporary dummy data for the tab view
                  flashcard: FlashcardEntity(
                    id: 'tab',
                    question: 'Select a deck to start',
                    answer: '...',
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quizzes',
                builder: (context, state) => const QuizzesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cases',
                builder: (context, state) => const CasesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
