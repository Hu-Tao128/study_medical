import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/theme/local_theme_repository.dart';
import 'core/network/backend_api.dart';
import 'features/auth/data/auth_service.dart';
import 'features/flashcard/data/flashcard_model.dart';
import 'features/flashcard/data/flashcard_repository.dart';
import 'features/flashcard/presentation/providers/flashcard_provider.dart';
import 'features/settings/presentation/providers/theme_provider.dart';
import 'features/settings/presentation/providers/locale_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(FlashcardModelAdapter());
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
    tokenProvider: () async =>
        await firebase_auth.FirebaseAuth.instance.currentUser?.getIdToken(),
  );

  final themeProvider = ThemeProvider(themeRepo);
  final localeProvider = LocaleProvider(themeRepo, backendApi);
  final profileProvider = ProfileProvider(backendApi: backendApi);

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
      ],
      child: const MyApp(),
    ),
  );
}
