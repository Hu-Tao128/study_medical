# AGENTS.md

This file is for coding agents working in `study_medical`.
It documents the real project workflow, conventions, and guardrails.
## 1) Project Snapshot
- Stack: Flutter + Dart, Provider, GoRouter, Firebase Auth/Core, Hive, l10n from ARB.
- Architecture: feature-first under `lib/features/*` with `data/`, `domain/`, `presentation/` splits where needed.
- Entry points: `lib/main.dart` (bootstrapping) and `lib/app.dart` (MaterialApp/router/theme/l10n).
- Router: centralized in `lib/core/router/app_router.dart`.
## 2) Environment and Setup
- Use stable Flutter/Dart (repo targets Dart `^3.10.3` in `pubspec.yaml`).
- Install deps first:
```bash
flutter pub get
```
- Firebase is expected for full auth behavior; local/test flows may run without full Firebase config.
## 3) Build, Lint, and Test Commands
Run from repository root: `study_medical`.
### Core daily commands
```bash
flutter pub get
flutter analyze
dart format .
flutter test
flutter run
```
### Build commands
```bash
flutter build apk
flutter build appbundle
flutter build ios --no-codesign
flutter build web
flutter build windows
```
### Localization and code generation
```bash
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
```
## 4) Single-Test Execution (Important)
Use one of these when running only part of the suite:
```bash
# single test file
flutter test test/widget_test.dart

# single test by exact name
flutter test test/widget_test.dart --plain-name "App smoke test"

# alternate (all files, filtered by test name)
flutter test --plain-name "App smoke test"
```
Useful output mode for CI/debugging:
```bash
flutter test -r expanded
```
## 5) Current Test/Lint Reality (as observed)
- `flutter analyze` currently reports 1 info in `login_page.dart` about `use_build_context_synchronously`.
- `flutter test` currently fails in `test/widget_test.dart` because `MyApp` is pumped without `Provider<AuthService>`.
- If you touch tests, prefer fixing root setup instead of bypassing failing assertions.
## 6) Import and File Organization Rules
- Keep feature-first layout under `lib/features/<feature>/...`.
- Prefer this import order in each file:
  1) Dart SDK imports (`dart:*`) if any.
  2) Third-party package imports (`package:flutter/...`, `package:provider/...`).
  3) Project-local imports (relative or `package:study_medical/...`, choose one style and keep it consistent per file).
- Keep one blank line between import groups.
- Avoid deep cross-feature coupling from UI widgets; route/service boundaries should remain clear.
## 7) Formatting and General Style
- Always run `dart format .` after edits.
- Respect lints from `analysis_options.yaml` (`flutter_lints`).
- Keep lines readable; let formatter decide wrapping.
- Prefer small widgets and extract private widgets (`_WidgetName`) for large build methods.
- Use trailing commas in widget trees to improve formatter output.
## 8) Dart/Flutter Type Guidelines
- Use sound null safety intentionally (`?` only when value can truly be absent).
- Prefer explicit types for fields, parameters, and local vars when clarity matters.
- Avoid `dynamic` unless absolutely necessary at API boundaries.
- At serialization boundaries, use `Map<String, dynamic>` and convert early to typed models/entities.
- Keep domain entities simple and immutable in practice (`final` fields, `copyWith` where helpful).
## 9) Naming Conventions
- Files: `snake_case.dart`.
- Classes/enums/typedefs: `PascalCase`.
- Methods/variables/params: `camelCase`.
- Private symbols: leading underscore (for file-private helpers/widgets/state).
- Constants: `camelCase` for Dart constants (`const`), not SCREAMING_CASE.
- Route paths: lowercase strings with leading slash (e.g., `/login`, `/settings`).
## 10) State Management and UI Logic
- `AuthService` (ChangeNotifier) is the auth source of truth and router refresh trigger.
- Keep business/auth logic in service/notifier layers, not inside widget trees.
- In widgets, use Provider access patterns intentionally:
  - `context.watch<T>()` for reactive rebuilds.
  - `context.read<T>()` for one-off actions.
- Minimize unnecessary rebuilds by scoping `watch` to the smallest subtree practical.
## 11) Async and Error Handling
- Wrap async auth/network actions with `try/catch` where user feedback is needed.
- Show actionable UI feedback (SnackBar/dialog) on failures.
- After `await`, guard UI operations with `if (!mounted) return;` in `State` classes.
- Do not silently swallow exceptions; either handle meaningfully or rethrow from service layer.
- Prefer typed exceptions when introducing new domain/service errors.
## 12) Navigation and Routing
- Add/update routes in `lib/core/router/app_router.dart`.
- Use `context.go()` for replacement-style navigation and tab/branch switching.
- Use `context.push()` when stacking a new page is the intent.
- Preserve auth redirect behavior (`isAuthenticated`, `/login`, `/register`, `/home`).
## 13) Localization Rules
- User-facing strings should come from `AppLocalizations.of(context)!`.
- Add new keys in both `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`.
- Regenerate localizations via `flutter gen-l10n` (or let Flutter auto-generate during build/test if enabled).
- Do not manually edit generated localization Dart files.
## 14) Generated and Platform Files
- Treat these as generated unless task explicitly requires regeneration/config updates:
  - `lib/l10n/app_localizations*.dart`
  - `lib/firebase_options.dart`
  - `ios/Flutter/*`, `windows/flutter/*`, and other Flutter generated registrant files.
- Prefer editing source configs (`pubspec.yaml`, ARB files, Dart source) then regenerate.
## 15) Agent Rules Discovery (Cursor/Copilot)
- Checked for Cursor/Copilot repo rules:
  - `.cursorrules`
  - `.cursor/rules/*`
  - `.github/copilot-instructions.md`
- Result: no such files currently exist in this repository.
- If these files are added later, update this AGENTS.md and follow them as highest-priority repo conventions.
## 16) Pre-PR / Pre-Commit Checklist for Agents
- Run `flutter analyze` and address warnings/errors introduced by your change.
- Run targeted tests first (single file/name), then full `flutter test` when feasible.
- Run `dart format .` and ensure no unintended generated-file churn.
- Keep changes scoped to the requested task; avoid opportunistic refactors.
- Note any known failing baseline tests separately from regressions you introduced.
## 17) High-Value Defaults for Future Agents
- Prefer minimal, surgical edits over broad rewrites.
- Preserve existing architecture (feature-first + provider + go_router).
- Keep localization and auth flow intact when changing UI.
- When uncertain, choose consistency with surrounding code over introducing new patterns.

## 18) Quick Do/Do Not
- Do keep changes scoped to the user request.
- Do verify routes, providers, and l10n keys when touching UI.
- Do prefer adding small widgets over large monolithic `build()` methods.
- Do not edit generated files manually unless explicitly required.
- Do not add new architectural patterns without a clear project need.
- Do not bypass failing tests by removing assertions; fix setup/root causes.

## 19) Handy Troubleshooting Notes
- If tests fail with `ProviderNotFoundException`, verify providers are wrapped in the test harness.
- If auth redirect behavior seems wrong, inspect `redirect` in `lib/core/router/app_router.dart`.
- If localized text does not appear, confirm ARB keys exist in both languages and run `flutter gen-l10n`.
- If Firebase errors appear locally, check whether `firebase_options.dart` is configured for that platform.
- If analyzer warnings mention async context use, prefer `if (!mounted) return;` before using `context` after `await`.
