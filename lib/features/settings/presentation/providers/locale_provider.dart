import 'package:flutter/material.dart';
import '../../../../core/theme/theme_repository.dart';

class LocaleProvider extends ChangeNotifier {
  final ThemeRepository _repository;
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider(this._repository);

  Future<void> init() async {
    _locale = await _repository.loadLocale();
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _repository.saveLocale(locale);
    notifyListeners();
  }

  static const supportedLocales = [Locale('en'), Locale('es')];

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode;
    }
  }
}
