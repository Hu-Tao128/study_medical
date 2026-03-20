# Study Medical 🏥

Study Medical is a mobile learning application for medical students and professionals. It provides interactive tools for studying, reviewing, and evaluating medical knowledge through flashcards, mini-exams, and clinical cases.

## 🚀 Technology Stack

- **Framework:** Flutter (v3.10.3+)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router) (using `StatefulShellRoute` for persistent bottom navigation)
- **Backend:** Firebase (Authentication, Core)
- **Localization:** Flutter standard localization with `.arb` files in `lib/l10n/`
- **Design:** Material 3

## 🏗️ Architecture

The project follows a **Feature-first** architecture combined with Clean Architecture principles within each feature:

```text
lib/
├── core/              # Central configuration (Router, Theme, Utils)
├── features/          # Domain-specific features
│   ├── auth/          # Authentication logic and UI
│   ├── home/          # Main dashboard and navigation shell
│   ├── flashcard/     # Memory card system
│   ├── quizzes/       # Exam and evaluation system
│   ├── cases/         # Clinical case studies
│   └── settings/      # User preferences and profile
├── l10n/             # Localization files
└── main.dart         # Entry point and Firebase initialization
```

## 🛠️ Building and Running

### Prerequisites
- Flutter SDK ^3.10.3
- Firebase CLI (for `flutterfire` configuration)

### Key Commands
- **Install Dependencies:** `flutter pub get`
- **Run Application:** `flutter run`
- **Run Tests:** `flutter test`
- **Generate Localizations:** `flutter gen-l10n` (Automatically triggered if `generate: true` is in `pubspec.yaml`)
- **Configure Firebase:** `flutterfire configure` (Requires Firebase CLI)

## 📝 Development Conventions

### Navigation
Navigation is centralized in `lib/core/router/app_router.dart`. Use `context.go()` or `context.push()` from `go_router`. Bottom navigation is managed via `StatefulShellRoute`.

### State Management
- Use `Provider` or `ChangeNotifierProvider` for global or feature-specific state.
- Business logic should be extracted from UI widgets into services or notifiers (e.g., `AuthService`).

### Localization
- Always use `AppLocalizations.of(context)!.key` for strings.
- Add new keys to `lib/l10n/app_es.arb` (default) and `lib/l10n/app_en.arb`.

### UI Components
- Favor Material 3 components and `Theme.of(context).colorScheme`.
- Complex UI should be broken down into smaller widgets within the `presentation/widgets/` directory of each feature.

### Firebase Integration
Firebase initialization occurs in `main.dart`. Ensure `firebase_options.dart` is generated before running the app. Auth state is used in the router to handle redirects.
