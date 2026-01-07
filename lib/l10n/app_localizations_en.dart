// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Study Medical';

  @override
  String get homeTitle => 'Home';

  @override
  String get flashcardsTitle => 'Flashcards';

  @override
  String get quizzesTitle => 'Quizzes';

  @override
  String get casesTitle => 'Clinical Cases';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get welcomeMessage => 'Welcome, Student!';

  @override
  String comingSoon(Object feature) {
    return '$feature coming soon!';
  }

  @override
  String get logoutButton => 'Log Out';
}
