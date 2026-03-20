import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_repository.dart';
import '../../core/theme/color_seed.dart';

class LocalThemeRepository implements ThemeRepository {
  static const _keyThemeMode = 'theme_mode';
  static const _keyColorSeed = 'color_seed';
  static const _keyLocale = 'locale';

  @override
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyThemeMode);
    return switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_keyThemeMode, value);
  }

  @override
  Future<ColorSeed> loadColorSeed() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_keyColorSeed) ?? ColorSeed.azul.storageKey;
    return ColorSeed.fromKey(key);
  }

  @override
  Future<void> saveColorSeed(ColorSeed seed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyColorSeed, seed.storageKey);
  }

  @override
  Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyLocale);
    return switch (value) {
      'es' => const Locale('es'),
      _ => const Locale('en'),
    };
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
  }
}
