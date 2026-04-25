import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/theme/local_theme_repository.dart';
import 'core/network/backend_api.dart';
import 'features/auth/data/auth_service.dart';
import 'features/flashcard/data/flashcard_model.dart';
import 'features/flashcard/data/flashcard_repository.dart';
import 'features/flashcard/presentation/providers/flashcard_provider.dart';
import 'features/notes/data/note_local_repository.dart';
import 'features/notes/data/note_model_adapter.dart';
import 'features/notes/data/note_repository.dart';
import 'features/notes/presentation/providers/note_provider.dart';
import 'features/profile/data/profile_local_repository.dart';
import 'features/profile/data/user_profile_adapter.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/settings/presentation/providers/theme_provider.dart';
import 'features/settings/presentation/providers/locale_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Hive.initFlutter();
  Hive.registerAdapter(FlashcardModelAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(SyncQueueItemAdapter());
  Hive.registerAdapter(NoteIdMappingAdapter());

  final notesLocalRepo = NoteLocalRepository();
  await notesLocalRepo.init();

  final profileLocalRepo = ProfileLocalRepository();
  await profileLocalRepo.init();

  await Hive.openBox('study_cache');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  final themeRepo = LocalThemeRepository();
  final backendApi = BackendApi(
    tokenProvider: () async {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      debugPrint('Firebase user: ${user?.uid}');
      final token = await user?.getIdToken();
      debugPrint('Token length: ${token?.length ?? 0}');
      return token;
    },
  );

  final noteRepository = NoteRepository(
    localRepo: notesLocalRepo,
    backendApi: backendApi,
  );
  final noteProvider = NoteProvider(repository: noteRepository);

  Connectivity().onConnectivityChanged.listen((result) async {
    if (!result.contains(ConnectivityResult.none)) {
      await noteRepository.syncWithServer();
      await noteProvider.loadNotes();
    }
  });

  final themeProvider = ThemeProvider(themeRepo);
  final localeProvider = LocaleProvider(themeRepo, backendApi);
  final profileProvider = ProfileProvider(
    localRepo: profileLocalRepo,
    backendApi: backendApi,
  );

  await themeProvider.init();
  await localeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: profileProvider),
        Provider<BackendApi>.value(value: backendApi),
        ChangeNotifierProvider(create: (_) => AuthService(backendApi)),
        ChangeNotifierProvider(
          create: (context) => FlashcardProvider(
            repository: FlashcardRepository(),
            backendApi: backendApi,
          ),
        ),
        ChangeNotifierProvider.value(value: noteProvider),
      ],
      child: const MyApp(),
    ),
  );
}
