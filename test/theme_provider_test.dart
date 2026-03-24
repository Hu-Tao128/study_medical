import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_medical/core/theme/color_seed.dart';
import 'package:study_medical/core/theme/theme_repository.dart';
import 'package:study_medical/features/settings/presentation/providers/theme_provider.dart';

class MockThemeRepository implements ThemeRepository {
  ThemeMode? _themeMode;
  ColorSeed? _colorSeed;
  Locale? _locale;

  @override
  Future<ThemeMode> loadThemeMode() async {
    return _themeMode ?? ThemeMode.system;
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    _themeMode = mode;
  }

  @override
  Future<ColorSeed> loadColorSeed() async {
    return _colorSeed ?? ColorSeed.azul;
  }

  @override
  Future<void> saveColorSeed(ColorSeed seed) async {
    _colorSeed = seed;
  }

  @override
  Future<Locale> loadLocale() async {
    return _locale ?? const Locale('en');
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    _locale = locale;
  }
}

void main() {
  group('ThemeProvider', () {
    late MockThemeRepository repository;
    late ThemeProvider provider;

    setUp(() {
      repository = MockThemeRepository();
      provider = ThemeProvider(repository);
    });

    test('should start with default values', () {
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.colorSeed, ColorSeed.azul);
    });

    test('should load saved values on init', () async {
      await provider.init();
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.colorSeed, ColorSeed.azul);
    });

    test('should update theme mode', () async {
      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
    });

    test('should update color seed', () async {
      await provider.setColorSeed(ColorSeed.rojo);
      expect(provider.colorSeed, ColorSeed.rojo);
    });

    test('should notify listeners on theme mode change', () async {
      var notified = false;
      provider.addListener(() => notified = true);
      await provider.setThemeMode(ThemeMode.light);
      expect(notified, true);
    });

    test('should notify listeners on color seed change', () async {
      var notified = false;
      provider.addListener(() => notified = true);
      await provider.setColorSeed(ColorSeed.morado);
      expect(notified, true);
    });
  });
}
