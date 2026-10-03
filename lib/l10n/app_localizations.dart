import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Medical'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @flashcardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcardsTitle;

  /// No description provided for @quizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzesTitle;

  /// No description provided for @casesTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical Cases'**
  String get casesTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Student!'**
  String get welcomeMessage;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} coming soon!'**
  String comingSoon(Object feature);

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutButton;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @hoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hoursLabel;

  /// No description provided for @coursesLabel.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesLabel;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @darkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeLabel;

  /// No description provided for @accentColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColorLabel;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders and alerts'**
  String get notificationsSubtitle;

  /// No description provided for @dailyGoalsSection.
  ///
  /// In en, this message translates to:
  /// **'Daily Goals'**
  String get dailyGoalsSection;

  /// No description provided for @dailyGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Goals'**
  String get dailyGoalsTitle;

  /// No description provided for @dailyGoalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'50 cards/day'**
  String get dailyGoalsSubtitle;

  /// No description provided for @reviewAlgorithmSection.
  ///
  /// In en, this message translates to:
  /// **'Review Algorithm'**
  String get reviewAlgorithmSection;

  /// No description provided for @reviewAlgorithmTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Algorithm'**
  String get reviewAlgorithmTitle;

  /// No description provided for @reviewAlgorithmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spaced Repetition'**
  String get reviewAlgorithmSubtitle;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @englishLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLabel;

  /// No description provided for @spanishLabel.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanishLabel;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @helpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenterTitle;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs and support'**
  String get helpCenterSubtitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get aboutSubtitle;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @gpaLabel.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get gpaLabel;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @flashcardSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Flashcard Session'**
  String get flashcardSessionTitle;

  /// No description provided for @sessionResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Result'**
  String get sessionResultTitle;

  /// No description provided for @aiQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Quiz Generator'**
  String get aiQuizTitle;

  /// No description provided for @aiExplainTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Explain'**
  String get aiExplainTitle;

  /// No description provided for @aiSummarizeTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Summarize'**
  String get aiSummarizeTitle;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteTitle;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your changes will be lost.'**
  String get discardChangesMessage;

  /// No description provided for @discardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @studyRelatedAnatomy.
  ///
  /// In en, this message translates to:
  /// **'Study Related Anatomy'**
  String get studyRelatedAnatomy;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @pleaseEnterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get pleaseEnterCredentials;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed'**
  String get googleSignInFailed;

  /// No description provided for @dailyGoalProgress.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal Progress'**
  String get dailyGoalProgress;

  /// No description provided for @topicsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count}/{total} topics completed'**
  String topicsCompleted(Object count, Object total);

  /// No description provided for @leftToday.
  ///
  /// In en, this message translates to:
  /// **'{count} left today'**
  String leftToday(Object count);

  /// No description provided for @interactive3DModels.
  ///
  /// In en, this message translates to:
  /// **'Interactive 3D Models'**
  String get interactive3DModels;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @anatomyLabel.
  ///
  /// In en, this message translates to:
  /// **'Anatomy'**
  String get anatomyLabel;

  /// No description provided for @theHumanHeart.
  ///
  /// In en, this message translates to:
  /// **'The Human Heart'**
  String get theHumanHeart;

  /// No description provided for @exploreHeartMechanics.
  ///
  /// In en, this message translates to:
  /// **'Explore chamber mechanics and valve structures in 3D.'**
  String get exploreHeartMechanics;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @neurologicalExams.
  ///
  /// In en, this message translates to:
  /// **'Neurological Exams'**
  String get neurologicalExams;

  /// No description provided for @moduleProgress.
  ///
  /// In en, this message translates to:
  /// **'Module {current} of {total} • {minutes} min'**
  String moduleProgress(Object current, Object minutes, Object total);

  /// No description provided for @ecgInterpretation.
  ///
  /// In en, this message translates to:
  /// **'ECG Interpretation'**
  String get ecgInterpretation;

  /// No description provided for @studyCenter.
  ///
  /// In en, this message translates to:
  /// **'Study Center'**
  String get studyCenter;

  /// No description provided for @chooseYourLearningMode.
  ///
  /// In en, this message translates to:
  /// **'Choose your learning mode'**
  String get chooseYourLearningMode;

  /// No description provided for @recent3DModels.
  ///
  /// In en, this message translates to:
  /// **'Recent 3D Models'**
  String get recent3DModels;

  /// No description provided for @heartAnatomy.
  ///
  /// In en, this message translates to:
  /// **'Heart Anatomy'**
  String get heartAnatomy;

  /// No description provided for @brainStructure.
  ///
  /// In en, this message translates to:
  /// **'Brain Structure'**
  String get brainStructure;

  /// No description provided for @skeletalSystem.
  ///
  /// In en, this message translates to:
  /// **'Skeletal System'**
  String get skeletalSystem;

  /// No description provided for @cardiologyLabel.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get cardiologyLabel;

  /// No description provided for @neurologyLabel.
  ///
  /// In en, this message translates to:
  /// **'Neurology'**
  String get neurologyLabel;

  /// No description provided for @quickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStart;

  /// No description provided for @browseTopics.
  ///
  /// In en, this message translates to:
  /// **'Browse Topics'**
  String get browseTopics;

  /// No description provided for @startNewFlashcardSession.
  ///
  /// In en, this message translates to:
  /// **'Start a new flashcard session'**
  String get startNewFlashcardSession;

  /// No description provided for @reviewDue.
  ///
  /// In en, this message translates to:
  /// **'Review Due'**
  String get reviewDue;

  /// No description provided for @cardsWaitingReview.
  ///
  /// In en, this message translates to:
  /// **'{count} cards waiting for review'**
  String cardsWaitingReview(Object count);

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @availableQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Available Quizzes'**
  String get availableQuizzes;

  /// No description provided for @questionsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Q'**
  String questionsLabel(Object count);

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesLabel(Object count);

  /// No description provided for @easyLabel.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easyLabel;

  /// No description provided for @mediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumLabel;

  /// No description provided for @hardLabel.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hardLabel;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @clinicalCases.
  ///
  /// In en, this message translates to:
  /// **'Clinical Cases'**
  String get clinicalCases;

  /// No description provided for @patientWithChestPain.
  ///
  /// In en, this message translates to:
  /// **'Patient with Chest Pain'**
  String get patientWithChestPain;

  /// No description provided for @acuteNeurologicalDeficit.
  ///
  /// In en, this message translates to:
  /// **'Acute Neurological Deficit'**
  String get acuteNeurologicalDeficit;

  /// No description provided for @pediatricRespiratoryDistress.
  ///
  /// In en, this message translates to:
  /// **'Pediatric Respiratory Distress'**
  String get pediatricRespiratoryDistress;

  /// No description provided for @medicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Medical Notes'**
  String get medicalNotes;

  /// No description provided for @searchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search pathology, anatomy, or clinical notes...'**
  String get searchNotesHint;

  /// No description provided for @allNotes.
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get allNotes;

  /// No description provided for @recentNotes.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentNotes;

  /// No description provided for @pinnedNotes.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinnedNotes;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @aiQuiz.
  ///
  /// In en, this message translates to:
  /// **'AI Quiz'**
  String get aiQuiz;

  /// No description provided for @aiExplain.
  ///
  /// In en, this message translates to:
  /// **'AI Explain'**
  String get aiExplain;

  /// No description provided for @aiSummarize.
  ///
  /// In en, this message translates to:
  /// **'AI Summarize'**
  String get aiSummarize;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStudy.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get navStudy;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navAI.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get navAI;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// No description provided for @featureComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'This feature is under development and will be available soon.'**
  String get featureComingSoonMessage;

  /// No description provided for @serverConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to server. Check your internet connection.'**
  String get serverConnectionError;

  /// No description provided for @offlineNoteWarning.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Changes will sync when you\'re back online.'**
  String get offlineNoteWarning;

  /// No description provided for @answerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answerLabel;

  /// No description provided for @studySetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Session'**
  String get studySetupTitle;

  /// No description provided for @studySetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a topic and start reviewing.'**
  String get studySetupSubtitle;

  /// No description provided for @selectTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get selectTopicLabel;

  /// No description provided for @cardsPerSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Cards per session'**
  String get cardsPerSessionLabel;

  /// No description provided for @cardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String cardsCount(String count);

  /// No description provided for @studyModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get studyModeLabel;

  /// No description provided for @modeFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get modeFlashcards;

  /// No description provided for @modeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get modeQuiz;

  /// No description provided for @modeCases.
  ///
  /// In en, this message translates to:
  /// **'Clinical cases'**
  String get modeCases;

  /// No description provided for @startStudyButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startStudyButton;

  /// No description provided for @noTopicsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No topics available'**
  String get noTopicsAvailable;

  /// No description provided for @noFlashcardsInTopic.
  ///
  /// In en, this message translates to:
  /// **'This topic has no flashcards yet'**
  String get noFlashcardsInTopic;

  /// No description provided for @sessionProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String sessionProgress(String current, String total);

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal the answer'**
  String get tapToReveal;

  /// No description provided for @rateYourRecall.
  ///
  /// In en, this message translates to:
  /// **'How well did you recall it?'**
  String get rateYourRecall;

  /// No description provided for @ratingAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get ratingAgain;

  /// No description provided for @ratingHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get ratingHard;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get ratingEasy;

  /// No description provided for @ratingPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get ratingPerfect;

  /// No description provided for @accuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracyLabel;

  /// No description provided for @studyAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Study again'**
  String get studyAgainButton;

  /// No description provided for @backToHomeButton.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHomeButton;

  /// No description provided for @sessionSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the session'**
  String get sessionSubmitFailed;

  /// No description provided for @answerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Answer not available'**
  String get answerUnavailable;

  /// No description provided for @progressByTopicTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress by topic'**
  String get progressByTopicTitle;

  /// No description provided for @progressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete a study session to see your progress'**
  String get progressEmpty;

  /// No description provided for @manageFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Manage flashcards'**
  String get manageFlashcards;

  /// No description provided for @newFlashcard.
  ///
  /// In en, this message translates to:
  /// **'New flashcard'**
  String get newFlashcard;

  /// No description provided for @editFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Edit flashcard'**
  String get editFlashcard;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// No description provided for @deleteFlashcardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete flashcard'**
  String get deleteFlashcardTitle;

  /// No description provided for @deleteFlashcardMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteFlashcardMessage;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @flashcardSaved.
  ///
  /// In en, this message translates to:
  /// **'Flashcard saved'**
  String get flashcardSaved;

  /// No description provided for @flashcardDeleted.
  ///
  /// In en, this message translates to:
  /// **'Flashcard deleted'**
  String get flashcardDeleted;

  /// No description provided for @noFlashcardsYet.
  ///
  /// In en, this message translates to:
  /// **'No flashcards in this topic yet'**
  String get noFlashcardsYet;

  /// No description provided for @createFirstFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Create the first one'**
  String get createFirstFlashcard;

  /// No description provided for @studyTopicButton.
  ///
  /// In en, this message translates to:
  /// **'Study this topic'**
  String get studyTopicButton;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @visibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibilityLabel;

  /// No description provided for @visibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get visibilityPrivate;

  /// No description provided for @visibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get visibilityPublic;

  /// No description provided for @visibilityGroup.
  ///
  /// In en, this message translates to:
  /// **'My group (coming soon)'**
  String get visibilityGroup;

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My documents'**
  String get myDocuments;

  /// No description provided for @uploadPdf.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get uploadPdf;

  /// No description provided for @uploadPdfHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a PDF to ask questions only about your file.'**
  String get uploadPdfHint;

  /// No description provided for @noDocuments.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocuments;

  /// No description provided for @documentReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get documentReady;

  /// No description provided for @documentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get documentProcessing;

  /// No description provided for @documentPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get documentPending;

  /// No description provided for @documentFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not process'**
  String get documentFailed;

  /// No description provided for @documentUploaded.
  ///
  /// In en, this message translates to:
  /// **'Document uploaded'**
  String get documentUploaded;

  /// No description provided for @documentUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the document'**
  String get documentUploadFailed;

  /// No description provided for @documentReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read the file'**
  String get documentReadFailed;

  /// No description provided for @aiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI is not configured on the server'**
  String get aiNotConfigured;

  /// No description provided for @askAboutDocument.
  ///
  /// In en, this message translates to:
  /// **'Ask this document. Answers cite the page.'**
  String get askAboutDocument;

  /// No description provided for @askHint.
  ///
  /// In en, this message translates to:
  /// **'Type your question...'**
  String get askHint;

  /// No description provided for @citations.
  ///
  /// In en, this message translates to:
  /// **'Citations'**
  String get citations;

  /// No description provided for @pageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String pageLabel(String page);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
