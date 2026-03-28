import 'package:flutter/material.dart';
import '../../../../core/network/backend_api.dart';
import '../../../profile/data/user_profile_model.dart';
import '../../../../core/theme/theme_repository.dart';

class LocaleProvider extends ChangeNotifier {
  final ThemeRepository _repository;
  final BackendApi _backendApi;
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider(this._repository, this._backendApi);

  Future<void> init() async {
    _locale = await _repository.loadLocale();
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _repository.saveLocale(locale);
    try {
      await _backendApi.updateProfile(
        ProfileUpdateRequest(preferredLanguage: locale.languageCode),
      );
    } catch (_) {
      // Ignore sync failures; local preference remains applied.
    }
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
