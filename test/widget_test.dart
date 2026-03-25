// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:study_medical/app.dart';
import 'package:study_medical/features/auth/data/auth_service.dart';
import 'package:study_medical/features/settings/presentation/providers/theme_provider.dart';
import 'package:study_medical/features/settings/presentation/providers/locale_provider.dart';
import 'package:study_medical/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:study_medical/features/flashcard/data/flashcard_model.dart';
import 'package:study_medical/core/theme/theme_repository.dart';
import 'package:study_medical/core/theme/color_seed.dart';

class FakeAuthService extends ChangeNotifier implements AuthService {
  @override
  AuthUser? get user => null;

  @override
  bool get isAuthenticated => false;

  @override
  bool get isRateLimited => false;

  @override
  int get failedAttempts => 0;

  @override
  bool get isInitialized => true;

  @override
  Future<AuthResult> signIn(String email, String password) async {
    return const AuthResult(success: false);
  }

  @override
  Future<AuthResult> signUp(String email, String password) async {
    return const AuthResult(success: false);
  }

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<String?> getToken() async => null;
}

class FakeThemeRepository implements ThemeRepository {
  @override
  Future<ThemeMode> loadThemeMode() async => ThemeMode.system;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {}

  @override
  Future<ColorSeed> loadColorSeed() async => ColorSeed.azul;

  @override
  Future<void> saveColorSeed(ColorSeed seed) async {}

  @override
  Future<Locale> loadLocale() async => const Locale('en');

  @override
  Future<void> saveLocale(Locale locale) async {}
}

class FakeThemeProvider extends ChangeNotifier implements ThemeProvider {
  @override
  ThemeMode get themeMode => ThemeMode.system;

  @override
  ColorSeed get colorSeed => ColorSeed.azul;

  @override
  Future<void> init() async {}

  @override
  Future<void> setThemeMode(ThemeMode mode) async {}

  @override
  Future<void> setColorSeed(ColorSeed seed) async {}
}

class FakeLocaleProvider extends ChangeNotifier implements LocaleProvider {
  @override
  Locale get locale => const Locale('en');

  @override
  Future<void> init() async {}

  @override
  Future<void> setLocale(Locale locale) async {}

  @override
  String getLanguageName(Locale locale) => 'English';
}

class FakeFlashcardProvider extends ChangeNotifier
    implements FlashcardProvider {
  @override
  List<FlashcardModel> get flashcards => [];

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  Future<void> loadFlashcards() async {}
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: FakeAuthService()),
          ChangeNotifierProvider<ThemeProvider>.value(
            value: FakeThemeProvider(),
          ),
          ChangeNotifierProvider<LocaleProvider>.value(
            value: FakeLocaleProvider(),
          ),
          ChangeNotifierProvider<FlashcardProvider>.value(
            value: FakeFlashcardProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
