import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/home/presentation/main_shell.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/model_3d_page.dart';
import '../../features/study/presentation/study_page.dart';
import '../../features/study/presentation/terminology_search_page.dart';
import '../../features/quizzes/presentation/quizzes_page.dart';
import '../../features/cases/presentation/cases_page.dart';
import '../../features/flashcard/data/study_session_model.dart';
import '../../features/flashcard/presentation/flashcard_form_page.dart';
import '../../features/flashcard/presentation/flashcard_list_page.dart';
import '../../features/flashcard/presentation/flashcard_session_page.dart';
import '../../features/flashcard/presentation/flashcard_result_page.dart';
import '../../features/flashcard/presentation/study_setup_page.dart';
import '../../features/notes/presentation/medical_notes_page.dart';
import '../../features/notes/presentation/note_detail_page.dart';
import '../../features/notes/presentation/note_editor_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/documents/presentation/document_chat_page.dart';
import '../../features/documents/presentation/documents_page.dart';
import '../../features/ai_assistant/presentation/ai_quiz_page.dart';
import '../../features/ai_assistant/presentation/ai_explain_page.dart';
import '../../features/ai_assistant/presentation/ai_summarize_page.dart';
import '../../features/settings/presentation/settings_page.dart';

GoRouter appRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: authService,
    redirect: (context, state) {
      final bool isLoggedIn = authService.isAuthenticated;
      final bool isLoggingIn = state.uri.path == '/login';
      final bool isRegistering = state.uri.path == '/register';

      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/model3d',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return Model3DPage(
            modelName: extra?['name'] ?? 'Modelo 3D',
            modelUrl: extra?['url'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/flashcards/:topicId',
        builder: (context, state) {
          final topicId = state.pathParameters['topicId'];
          if (topicId == null || topicId.isEmpty) {
            return const StudySetupPage();
          }
          return FlashcardListPage(
            topicId: topicId,
            topicName: state.extra is String ? state.extra as String : null,
          );
        },
      ),
      GoRoute(
        path: '/flashcards/:topicId/new',
        builder: (context, state) =>
            FlashcardFormPage(topicId: state.pathParameters['topicId'] ?? ''),
      ),
      GoRoute(
        path: '/flashcards/:topicId/:id/edit',
        builder: (context, state) => FlashcardFormPage(
          topicId: state.pathParameters['topicId'] ?? '',
          flashcardId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/study/flashcards/setup',
        builder: (context, state) => StudySetupPage(
          initialTopicId: state.uri.queryParameters['topicId'],
        ),
      ),
      GoRoute(
        path: '/study/flashcards/session',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is StudySessionLaunch) {
            return FlashcardSessionPage(launch: extra);
          }
          // Deep link sin sesión activa: se vuelve al setup.
          return const StudySetupPage();
        },
      ),
      GoRoute(
        path: '/study/quizzes',
        builder: (context, state) => const QuizzesPage(),
      ),
      GoRoute(
        path: '/study/cases',
        builder: (context, state) => const CasesPage(),
      ),
      GoRoute(
        path: '/study/terminology',
        builder: (context, state) => const TerminologySearchPage(),
      ),
      GoRoute(
        path: '/study/flashcards/result',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is StudySessionResult) {
            return FlashcardResultPage(result: extra);
          }
          return const StudySetupPage();
        },
      ),
      GoRoute(
        path: '/notes/new',
        builder: (context, state) => const NoteEditorPage(),
      ),
      GoRoute(
        path: '/notes/:id',
        builder: (context, state) {
          final noteId = state.pathParameters['id'];
          if (noteId == null ||
              noteId.isEmpty ||
              !RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(noteId)) {
            return const MedicalNotesPage();
          }
          return NoteDetailPage(noteId: noteId);
        },
      ),
      GoRoute(
        path: '/notes/:id/edit',
        builder: (context, state) {
          final noteId = state.pathParameters['id'];
          if (noteId == null || noteId.isEmpty) {
            return const MedicalNotesPage();
          }
          return NoteEditorPage(noteId: noteId);
        },
      ),
      GoRoute(
        path: '/ai/quiz',
        builder: (context, state) => const AIQuizPage(),
      ),
      GoRoute(
        path: '/ai/explain',
        builder: (context, state) => const AIExplainPage(),
      ),
      GoRoute(
        path: '/ai/summarize',
        builder: (context, state) => const AISummarizePage(),
      ),
      GoRoute(
        path: '/documents/:id',
        builder: (context, state) => DocumentChatPage(
          documentId: state.pathParameters['id'] ?? '',
          documentName: state.extra is String ? state.extra as String : null,
        ),
      ),
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
                path: '/study',
                builder: (context, state) => const StudyPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const MedicalNotesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ai',
                builder: (context, state) => const DocumentsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
