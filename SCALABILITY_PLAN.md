# Plan de Escalabilidad y Despliegue

> Generado el: 2026-03-20 | Auditor: Skill `auditor-escalabilidad`

## Resumen Ejecutivo

El proyecto `study_medical` es una app Flutter/Android funcional con autenticación Firebase, almacenamiento local con Hive y UI con Provider/GoRouter. El código Dart es limpio y sigue las convenciones del proyecto. Sin embargo, existen **4 hallazgos críticos** que impiden el despliegue fuera del entorno local: (1) rutas absolutas hardcodeadas en `local.properties`, (2) API keys y credenciales de Firebase en el repositorio, (3) ausencia total de pipeline CI/CD, y (4) `applicationId` genérico `com.example.*` incompatible con publicación en stores. El riesgo global es **🔴 Crítico** para despliegues automatizados y **🟡 Alto** para publicación en producción.

## 🔴 Hallazgos Críticos

### HC-01: Rutas absolutas hardcodeadas en `local.properties`
- **Archivo(s):** `android/local.properties:1-2`
- **Descripción:** El archivo `local.properties` contiene rutas absolutas específicas de la máquina del desarrollador:
  ```
  sdk.dir=/home/aya/Android/Sdk
  flutter.sdk=/home/aya/develop/flutter
  ```
  Estas rutas no existen en ninguna otra máquina ni en CI/CD, por lo que `flutter build apk` fallará inmediatamente fuera del entorno original.
- **Impacto:** El build de Android no puede ejecutarse en CI/CD ni en la máquina de ningún otro desarrollador. Todo el proceso de despliegue está bloqueado.
- **Solución propuesta:** Eliminar `local.properties` del repositorio (ya está en `.gitignore`?) y generar las rutas dinámicamente, o mejor aún, no versionar este archivo. Verificar que esté en `.gitignore` y que cada entorno genere el suyo propio.

### HC-02: API keys y project ID de Firebase en código fuente
- **Archivo(s):** `lib/firebase_options.dart:43-87`, `android/app/google-services.json`
- **Descripción:** Las credenciales de Firebase (API keys, project ID, app IDs, messaging sender IDs) están hardcodeadas en texto plano en `lib/firebase_options.dart` y `android/app/google-services.json`. Esto expone las credenciales en el historial de git y las hace visibles a cualquier persona con acceso al repositorio.
- **Impacto:** Exposición de credenciales en repositorio público/privado. Riesgo de uso no autorizado del proyecto Firebase. Imposibilidad de tener entornos staging/producción separados.
- **Solución propuesta:** Migrar las opciones de Firebase a variables de entorno leídas en tiempo de ejecución. Usar el paquete `flutter_dotenv` o la configuración por flavours de Gradle (build types `debug`/`release` con distintos `google-services.json`). Separar los proyectos Firebase de staging y producción.

### HC-03: Ausencia completa de pipeline CI/CD
- **Archivo(s):** N/A (no existe `.github/workflows/`)
- **Descripción:** No existe ningún workflow de GitHub Actions ni ningún otro sistema de CI/CD. No hay configuración para compilar, testear ni desplegar la aplicación automáticamente. El release de builds depende de un desarrollador específico con acceso a Flutter instalado localmente.
- **Impacto:** Sin CI/CD no hay integración continua, ni tests automatizados en cada commit, ni builds reproducibles, ni despliegues a stores. El proceso de publicación es 100% manual.
- **Solución propuesta:** Crear `.github/workflows/` con al menos dos workflows: (1) `ci.yml` para lint, analyze, test y build en cada push/PR, y (2) `release.yml` para build y firma de APKs/AAB con GitHub Releases. Usar el Flutter setup action con cache de dependencias.

### HC-04: `applicationId` genérico `com.example.study_medical` en todos los flavours
- **Archivo(s):** `android/app/build.gradle.kts:27`
- **Descripción:** El `applicationId` es `com.example.study_medical` en todos los flavours (debug, release). El namespace de Kotlin también es `com.example.study_medical` (`android/app/build.gradle.kts:12`). Los paquetes `com.example.*` están reservados/bloqueados en Google Play Store y no pasan la validación de publicación.
- **Impacto:** La app no puede publicarse en Google Play Store. Conflictos de firma con otras apps `com.example` en dispositivos de usuarios.
- **Solución propuesta:** Cambiar `applicationId` y namespace a un dominio invertido propio (ej. `com.studymedical.app`) antes de cualquier publicación. Implementar flavours (`flavorDimensions += "environment"` con `dev`, `staging`, `prod`) para gestionar diferentes environments.

## 🟡 Deuda Técnica

### DT-01: Fiturones AI vacíos (AI Assistant, Explain, Summarize, Quiz)
- **Área:** Frontend / Negocio
- **Descripción:** Las 4 páginas del módulo AI (`ai_chat_page.dart`, `ai_explain_page.dart`, `ai_summarize_page.dart`, `ai_quiz_page.dart`) son implementaciones placeholder con solo UI estática y el texto "Coming soon". No hay conexión a ningún modelo ni API de IA. Si la intención es usar Ollama local o una API remota, el scaffolding de integración no existe.
- **Esfuerzo estimado:** 3–5 días para implementar la integración con un proveedor de IA (Ollama local, OpenAI, Gemini) con fallback robusto.

### DT-02: Datos de flashcards hardcodeados en memoria
- **Área:** Frontend / Datos
- **Descripción:** En `flashcard_provider.dart:30-46` los datos de flashcards están instanciados como constantes en memoria (mock data). No existe integración con Firebase Firestore ni con ninguna base de datos remota. El flujo completo de cache-local → backend → actualización no puede probarse.
- **Esfuerzo estimado:** 1–2 días para migrar a Firestore con reglas de seguridad básicas.

### DT-03: Tests fallando en el harness base
- **Área:** DevOps / Testing
- **Descripción:** `test/widget_test.dart` falla porque `MyApp` es pump sin `Provider<FlashcardProvider>` (que a su vez necesita `Hive` inicializado). La solución actual (fakes) está incompleta — falta el `FakeFlashcardProvider` y no se mocked `Hive`. Esto indica que no hay testing automatizado funcional.
- **Esfuerzo estimado:** 2–4 horas para corregir el harness y hacer pasar el smoke test.

### DT-04: package bundle ID inconsistente entre plataformas
- **Área:** Distribución
- **Descripción:** iOS/macOS usan `com.example.studyMedical` (`lib/firebase_options.dart:67,76`) mientras Android usa `com.example.study_medical`. Esto puede causar problemas de firma y de linking Firebase entre plataformas. Además, el bundle ID no coincide con el nombre del paquete (`com.example.study_medical` vs `com.example.studyMedical`).
- **Esfuerzo estimado:** 30 minutos para unificar a `com.studymedical.app` (o el dominio elegido en HC-04).

### DT-05: Build de iOS sin configuración de firma
- **Área:** DevOps / Distribución
- **Descripción:** `ios/Runner/GoogleService-Info.plist` no existe, y no hay configuración de firma (signing) en el proyecto iOS. Los workflows de CI no podrán compilar el target iOS sin perfiles de provisioning y certificates configurados como secretos de GitHub.
- **Esfuerzo estimado:** 2–3 horas para configurar CI de iOS con Fastlane o flutter build ipa y secretos de GitHub Actions.

### DT-06: Sin estrategia de gestión de errores en operaciones async
- **Área:** Frontend / Calidad
- **Descripción:** `AuthService.signIn`/`signUp` no tienen try/catch con feedback al usuario. `FlashcardProvider.loadFlashcards` captura errores genéricos en `_error` pero no hay UI que los exponga. No existe un `GlobalErrorHandler` ni un sistema de logging estructurado.
- **Esfuerzo estimado:** 1 día para implementar error boundaries y SnackBar/feedback consistente.

### DT-07: Dependencias con versiones flojas (caret syntax)
- **Área:** DevOps / Mantenimiento
- **Descripción:** Muchas dependencias en `pubspec.yaml` usan sintaxis de versión floja (ej. `firebase_core: ^4.3.0`, `google_sign_in: ^6.2.1`). Esto permite actualizaciones menores que podrían romper compatibilidad. No hay lock file pinning ni Renovate/Dependabot configurado.
- **Esfuerzo estimado:** 1 hora para configurar Dependabot en GitHub Actions para actualizaciones automáticas de dependencias.

### DT-08: Sin flavour/build variants para entornos
- **Área:** DevOps / Distribución
- **Descripción:** No existen build variants para desarrollo, staging y producción. Toda la app usa la misma configuración de Firebase (`studymedical` proyecto único). Esto impide testing en producción-real sin afectar datos reales.
- **Esfuerzo estimado:** 2–3 días para configurar flavours en Gradle con distintos proyectos Firebase y configuración de API base.

## 📋 Plan de Acción

### Corto Plazo (0–2 semanas) — Desbloquear el Despliegue
- [ ] HC-01: Verificar que `android/local.properties` esté en `.gitignore`. Si no lo está, agregarlo. Limpiar cualquier versión versionada del archivo del historial con `git filter-branch` o BFG.
- [ ] HC-02: Migrar `firebase_options.dart` para leer de `.env` con `flutter_dotenv` (solo para Web/Desktop). Para Android/iOS, usar Firebase flavours con `google-services.json` por variant. Remover `google-services.json` del repositorio y agregarlo a `.gitignore`; documentar que debe bajarse de Firebase Console por entorno.
- [ ] HC-03: Crear `.github/workflows/ci.yml` con: checkout → Flutter setup (con cache) → `flutter pub get` → `flutter analyze` → `flutter test` → `flutter build apk --debug`. Agregar `workflow_dispatch` para builds manuales.
- [ ] HC-04: Cambiar `applicationId` y namespace de Android de `com.example.study_medical` a un dominio propio. Actualizar iOS bundle ID a la vez para mantener consistencia.

### Mediano Plazo (1–3 meses) — Reducir Deuda Técnica
- [ ] DT-03: Corregir `test/widget_test.dart` agregando `FakeFlashcardProvider` al harness y mockeando `Hive.initFlutter()` con `hive_flutter` en modo test.
- [ ] DT-02: Integrar `FlashcardRepository` con Firebase Firestore. Mantener Hive como cache offline-first.
- [ ] DT-01: Diseñar e implementar la arquitectura de integración AI (elegir proveedor: Ollama local, OpenAI, Gemini). Implementar con patrón Repository para poder cambiar de proveedor sin cambiar la UI.
- [ ] DT-06: Agregar try/catch con feedback visual en `AuthService.signIn`/`signUp` y `FlashcardProvider`. Implementar un `ErrorSnackBar` util.
- [ ] DT-07: Configurar Dependabot para `pubspec.yaml` en `.github/dependabot.yml`.

### Largo Plazo (3–6 meses) — Escalabilidad y Distribución
- [ ] HC-03: Expandir CI con `release.yml` para builds de APK firmados, AAB para Play Store, e IPA para TestFlight. Configurar GitHub Environments (`staging`, `production`) con distintos secretos.
- [ ] DT-08: Implementar flavours Android (`dev`, `staging`, `prod`) con distintos proyectos Firebase y endpoints de API. Configurar GitHub Actions para promover builds entre environments.
- [ ] Publicar en Google Play Store (internal testing → closed → open) con el bundle ID correcto.
- [ ] Documentar proceso de onboarding: requisitos de entorno, cómo obtener credenciales Firebase por entorno, cómo configurar signing keys, cómo ejecutar CI localmente.
