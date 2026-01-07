// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Estudio Médico';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get flashcardsTitle => 'Tarjetas';

  @override
  String get quizzesTitle => 'Cuestionarios';

  @override
  String get casesTitle => 'Casos Clínicos';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get welcomeMessage => '¡Bienvenido, Estudiante!';

  @override
  String comingSoon(Object feature) {
    return '¡$feature próximamente!';
  }

  @override
  String get logoutButton => 'Cerrar Sesión';
}
