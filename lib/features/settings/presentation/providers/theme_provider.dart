import 'package:flutter/material.dart';
import '../../../../core/theme/theme_repository.dart';
import '../../../../core/theme/color_seed.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeRepository _repository;

  ThemeMode _themeMode = ThemeMode.system;
  ColorSeed _colorSeed = ColorSeed.azul;

  ThemeMode get themeMode => _themeMode;
  ColorSeed get colorSeed => _colorSeed;

  ThemeProvider(this._repository);

  Future<void> init() async {
    _themeMode = await _repository.loadThemeMode();
    _colorSeed = await _repository.loadColorSeed();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _repository.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> setColorSeed(ColorSeed seed) async {
    _colorSeed = seed;
    await _repository.saveColorSeed(seed);
    notifyListeners();
  }
}
