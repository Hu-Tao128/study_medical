import 'package:flutter/material.dart';
import 'color_seed.dart';

abstract class ThemeRepository {
  Future<ThemeMode> loadThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
  Future<ColorSeed> loadColorSeed();
  Future<void> saveColorSeed(ColorSeed seed);
  Future<Locale> loadLocale();
  Future<void> saveLocale(Locale locale);
}
