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

  @override
  String get profileTitle => 'Profile';

  @override
  String get hoursLabel => 'Hours';

  @override
  String get coursesLabel => 'Courses';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get darkModeLabel => 'Dark Mode';

  @override
  String get accentColorLabel => 'Accent Color';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get systemDefault => 'System default';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Reminders and alerts';

  @override
  String get dailyGoalsSection => 'Daily Goals';

  @override
  String get dailyGoalsTitle => 'Daily Goals';

  @override
  String get dailyGoalsSubtitle => '50 cards/day';

  @override
  String get reviewAlgorithmSection => 'Review Algorithm';

  @override
  String get reviewAlgorithmTitle => 'Review Algorithm';

  @override
  String get reviewAlgorithmSubtitle => 'Spaced Repetition';

  @override
  String get languageSection => 'Language';

  @override
  String get languageTitle => 'Language';

  @override
  String get englishLabel => 'English';

  @override
  String get spanishLabel => 'Spanish';

  @override
  String get supportSection => 'Support';

  @override
  String get helpCenterTitle => 'Help Center';

  @override
  String get helpCenterSubtitle => 'FAQs and support';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSubtitle => 'Version 1.0.0';

  @override
  String get logoutConfirmTitle => 'Log Out';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get gpaLabel => 'GPA';

  @override
  String get signInButton => 'Sign In';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get registerButton => 'Register';

  @override
  String get flashcardSessionTitle => 'Flashcard Session';

  @override
  String get sessionResultTitle => 'Session Result';

  @override
  String get aiQuizTitle => 'AI Quiz Generator';

  @override
  String get aiExplainTitle => 'AI Explain';

  @override
  String get aiSummarizeTitle => 'AI Summarize';

  @override
  String get noteTitle => 'Note';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage => 'Your changes will be lost.';

  @override
  String get discardButton => 'Discard';

  @override
  String get saveButton => 'Save';

  @override
  String get retryButton => 'Retry';

  @override
  String get studyRelatedAnatomy => 'Study Related Anatomy';

  @override
  String get searchHint => 'Search...';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get pleaseEnterCredentials => 'Please enter email and password';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get googleSignInFailed => 'Google Sign-In failed';

  @override
  String get dailyGoalProgress => 'Daily Goal Progress';

  @override
  String topicsCompleted(Object count, Object total) {
    return '$count/$total topics completed';
  }

  @override
  String leftToday(Object count) {
    return '$count left today';
  }

  @override
  String get interactive3DModels => 'Interactive 3D Models';

  @override
  String get viewAll => 'View All';

  @override
  String get newLabel => 'New';

  @override
  String get anatomyLabel => 'Anatomy';

  @override
  String get theHumanHeart => 'The Human Heart';

  @override
  String get exploreHeartMechanics =>
      'Explore chamber mechanics and valve structures in 3D.';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get neurologicalExams => 'Neurological Exams';

  @override
  String moduleProgress(Object current, Object minutes, Object total) {
    return 'Module $current of $total • $minutes min';
  }

  @override
  String get ecgInterpretation => 'ECG Interpretation';

  @override
  String get studyCenter => 'Study Center';

  @override
  String get chooseYourLearningMode => 'Choose your learning mode';

  @override
  String get recent3DModels => 'Recent 3D Models';

  @override
  String get heartAnatomy => 'Heart Anatomy';

  @override
  String get brainStructure => 'Brain Structure';

  @override
  String get skeletalSystem => 'Skeletal System';

  @override
  String get cardiologyLabel => 'Cardiology';

  @override
  String get neurologyLabel => 'Neurology';

  @override
  String get quickStart => 'Quick Start';

  @override
  String get browseTopics => 'Browse Topics';

  @override
  String get startNewFlashcardSession => 'Start a new flashcard session';

  @override
  String get reviewDue => 'Review Due';

  @override
  String cardsWaitingReview(Object count) {
    return '$count cards waiting for review';
  }

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get todayLabel => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get availableQuizzes => 'Available Quizzes';

  @override
  String questionsLabel(Object count) {
    return '$count Q';
  }

  @override
  String minutesLabel(Object count) {
    return '$count min';
  }

  @override
  String get easyLabel => 'Easy';

  @override
  String get mediumLabel => 'Medium';

  @override
  String get hardLabel => 'Hard';

  @override
  String get startButton => 'Start';

  @override
  String get clinicalCases => 'Clinical Cases';

  @override
  String get patientWithChestPain => 'Patient with Chest Pain';

  @override
  String get acuteNeurologicalDeficit => 'Acute Neurological Deficit';

  @override
  String get pediatricRespiratoryDistress => 'Pediatric Respiratory Distress';

  @override
  String get medicalNotes => 'Medical Notes';

  @override
  String get searchNotesHint =>
      'Search pathology, anatomy, or clinical notes...';

  @override
  String get allNotes => 'All Notes';

  @override
  String get recentNotes => 'Recent';

  @override
  String get pinnedNotes => 'Pinned';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get aiQuiz => 'AI Quiz';

  @override
  String get aiExplain => 'AI Explain';

  @override
  String get aiSummarize => 'AI Summarize';

  @override
  String get editNote => 'Edit Note';

  @override
  String get newNote => 'New Note';

  @override
  String get navHome => 'Home';

  @override
  String get navStudy => 'Study';

  @override
  String get navLibrary => 'Library';

  @override
  String get navAI => 'AI';

  @override
  String get navProfile => 'Profile';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get featureComingSoonMessage =>
      'This feature is under development and will be available soon.';

  @override
  String get serverConnectionError =>
      'Could not connect to server. Check your internet connection.';

  @override
  String get offlineNoteWarning =>
      'You\'re offline. Changes will sync when you\'re back online.';
}
