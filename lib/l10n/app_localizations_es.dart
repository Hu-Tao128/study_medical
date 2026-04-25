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

  @override
  String get profileTitle => 'Perfil';

  @override
  String get hoursLabel => 'Horas';

  @override
  String get coursesLabel => 'Cursos';

  @override
  String get appearanceSection => 'Apariencia';

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get darkModeLabel => 'Modo Oscuro';

  @override
  String get accentColorLabel => 'Color de Acento';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get notificationsSection => 'Notificaciones';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get notificationsSubtitle => 'Recordatorios y alertas';

  @override
  String get dailyGoalsSection => 'Metas Diarias';

  @override
  String get dailyGoalsTitle => 'Metas Diarias';

  @override
  String get dailyGoalsSubtitle => '50 tarjetas/día';

  @override
  String get reviewAlgorithmSection => 'Algoritmo de Repaso';

  @override
  String get reviewAlgorithmTitle => 'Algoritmo de Repaso';

  @override
  String get reviewAlgorithmSubtitle => 'Repetición Espaciada';

  @override
  String get languageSection => 'Idioma';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get englishLabel => 'Inglés';

  @override
  String get spanishLabel => 'Español';

  @override
  String get supportSection => 'Soporte';

  @override
  String get helpCenterTitle => 'Centro de Ayuda';

  @override
  String get helpCenterSubtitle => 'Preguntas frecuentes y soporte';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutSubtitle => 'Versión 1.0.0';

  @override
  String get logoutConfirmTitle => 'Cerrar Sesión';

  @override
  String get logoutConfirmMessage =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get gpaLabel => 'Promedio';

  @override
  String get signInButton => 'Iniciar Sesión';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get flashcardSessionTitle => 'Sesión de Tarjetas';

  @override
  String get sessionResultTitle => 'Resultado de la Sesión';

  @override
  String get aiQuizTitle => 'Generador de Cuestionarios IA';

  @override
  String get aiExplainTitle => 'Explicar con IA';

  @override
  String get aiSummarizeTitle => 'Resumir con IA';

  @override
  String get noteTitle => 'Nota';

  @override
  String get discardChangesTitle => '¿Descartar cambios?';

  @override
  String get discardChangesMessage => 'Se perderán los cambios.';

  @override
  String get discardButton => 'Descartar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get studyRelatedAnatomy => 'Anatomía Relacionada';

  @override
  String get searchHint => 'Buscar...';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar Contraseña';

  @override
  String get pleaseEnterCredentials => 'Por favor ingresa correo y contraseña';

  @override
  String get loginFailed => 'Error al iniciar sesión';

  @override
  String get registrationFailed => 'Error al registrarse';

  @override
  String get pleaseFillAllFields => 'Por favor completa todos los campos';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get googleSignInFailed => 'Error de Google Sign-In';

  @override
  String get dailyGoalProgress => 'Progreso de Meta Diaria';

  @override
  String topicsCompleted(Object count, Object total) {
    return '$count/$total temas completados';
  }

  @override
  String leftToday(Object count) {
    return '$count restantes hoy';
  }

  @override
  String get interactive3DModels => 'Modelos 3D Interactivos';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get newLabel => 'Nuevo';

  @override
  String get anatomyLabel => 'Anatomía';

  @override
  String get theHumanHeart => 'El Corazón Humano';

  @override
  String get exploreHeartMechanics =>
      'Explora la mecánica de las cámaras y estructuras valvulares en 3D.';

  @override
  String get continueLearning => 'Continuar Aprendiendo';

  @override
  String get neurologicalExams => 'Exámenes Neurológicos';

  @override
  String moduleProgress(Object current, Object minutes, Object total) {
    return 'Módulo $current de $total • $minutes min';
  }

  @override
  String get ecgInterpretation => 'Interpretación de ECG';

  @override
  String get studyCenter => 'Centro de Estudio';

  @override
  String get chooseYourLearningMode => 'Elige tu modo de aprendizaje';

  @override
  String get recent3DModels => 'Modelos 3D Recientes';

  @override
  String get heartAnatomy => 'Anatomía del Corazón';

  @override
  String get brainStructure => 'Estructura Cerebral';

  @override
  String get skeletalSystem => 'Sistema Esquelético';

  @override
  String get cardiologyLabel => 'Cardiología';

  @override
  String get neurologyLabel => 'Neurología';

  @override
  String get quickStart => 'Inicio Rápido';

  @override
  String get browseTopics => 'Explorar Temas';

  @override
  String get startNewFlashcardSession => 'Inicia una nueva sesión de tarjetas';

  @override
  String get reviewDue => 'Repaso Pendiente';

  @override
  String cardsWaitingReview(Object count) {
    return '$count tarjetas esperando revisión';
  }

  @override
  String get yourProgress => 'Tu Progreso';

  @override
  String get todayLabel => 'Hoy';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get availableQuizzes => 'Cuestionarios Disponibles';

  @override
  String questionsLabel(Object count) {
    return '$count P';
  }

  @override
  String minutesLabel(Object count) {
    return '$count min';
  }

  @override
  String get easyLabel => 'Fácil';

  @override
  String get mediumLabel => 'Medio';

  @override
  String get hardLabel => 'Difícil';

  @override
  String get startButton => 'Iniciar';

  @override
  String get clinicalCases => 'Casos Clínicos';

  @override
  String get patientWithChestPain => 'Paciente con Dolor Torácico';

  @override
  String get acuteNeurologicalDeficit => 'Déficit Neurológico Agudo';

  @override
  String get pediatricRespiratoryDistress =>
      'Dificultad Respiratoria Pediátrica';

  @override
  String get medicalNotes => 'Notas Médicas';

  @override
  String get searchNotesHint =>
      'Buscar patología, anatomía o notas clínicas...';

  @override
  String get allNotes => 'Todas las Notas';

  @override
  String get recentNotes => 'Recientes';

  @override
  String get pinnedNotes => 'Fijadas';

  @override
  String get aiAssistant => 'Asistente IA';

  @override
  String get aiQuiz => 'Cuestionario IA';

  @override
  String get aiExplain => 'Explicar IA';

  @override
  String get aiSummarize => 'Resumir IA';

  @override
  String get editNote => 'Editar Nota';

  @override
  String get newNote => 'Nueva Nota';

  @override
  String get navHome => 'Inicio';

  @override
  String get navStudy => 'Estudio';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navAI => 'IA';

  @override
  String get navProfile => 'Perfil';

  @override
  String get featureComingSoon => 'Función próximamente';

  @override
  String get featureComingSoonMessage =>
      'Esta función está en desarrollo y estará disponible pronto.';

  @override
  String get serverConnectionError =>
      'No se pudo conectar al servidor. Verifica tu conexión a internet.';

  @override
  String get offlineNoteWarning =>
      'Estás sin conexión. Los cambios se sincronizarán cuando vuelvas a estar online.';
}
