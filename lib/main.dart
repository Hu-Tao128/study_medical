import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'data/theme/local_theme_repository.dart';
import 'features/auth/data/auth_service.dart';
import 'features/flashcard/data/flashcard_model.dart';
import 'features/flashcard/presentation/providers/flashcard_provider.dart';
import 'features/settings/presentation/providers/theme_provider.dart';
import 'features/settings/presentation/providers/locale_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(FlashcardModelAdapter());
  await Hive.openBox('study_cache');

  try {
    await Supabase.initialize(
      url: 'https://spxgotrytjkofqinsklw.supabase.co',
      anonKey: 'sb_publishable_99i1vspo1ocJ5-PLAuMmgg_fRlCFbL1',
    );
  } catch (e) {
    debugPrint("Supabase init failed: $e");
  }

  final themeRepo = LocalThemeRepository();
  final themeProvider = ThemeProvider(themeRepo);
  final localeProvider = LocaleProvider(themeRepo);
  await themeProvider.init();
  await localeProvider.init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed (expected if not configured): $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FlashcardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
