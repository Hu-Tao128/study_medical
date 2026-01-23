# Study Medical 🏥

Una aplicación móvil de aprendizaje de medicina diseñada para estudiantes de medicina y profesionales en formación. Study Medical proporciona herramientas interactivas para el estudio, repaso y evaluación de conocimientos médicos.

## 🎯 Características Principales

### 📚 Modelos 3D Interactivos
- Explora anatomía humana con modelos 3D detallados
- Visualización de estructuras médicas complejas
- Navegación intuitiva y zoom para estudio detallado

### 🎴 Flashcards Médicas
- Sistema de tarjetas de memoria para terminología médica
- Categorías por especialidades médicas
- Método de repetición espaciada para optimizar el aprendizaje

### 📝 Mini Exámenes
- Evaluaciones rápidas sobre temas específicos
- Preguntas tipo opción múltiple y verdadero/falso
- Retroalimentación inmediata y estadísticas de progreso

### 🏥 Casos Clínicos
- Estudio de casos clínicos reales y simulados
- Aplicación práctica de conocimientos teóricos
- Guía paso a paso para diagnóstico y tratamiento

## 🚀 Tecnologías Utilizadas

- **Flutter** - Framework de desarrollo multiplataforma
- **Firebase** - Autenticación y base de datos
- **Provider** - Gestión de estado
- **Go Router** - Navegación y routing
- **Material Design** - Interfaz de usuario moderna

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS
- ✅ Web (en desarrollo)

## 🛠️ Instalación

### Prerrequisitos
- Flutter SDK (versión 3.10.3 o superior)
- Dart SDK
- Android Studio / VS Code
- Emulador o dispositivo físico

### Pasos de Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/study_medical.git
cd study_medical
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Configura Firebase:
```bash
flutterfire configure
```

4. Ejecuta la aplicación:
```bash
flutter run
```

## 📖 Uso de la Aplicación

### Para Estudiantes de Medicina
- **Estudio Diario**: Utiliza las flashcards para repasar terminología
- **Preparación de Exámenes**: Realiza mini exámenes para evaluar tu conocimiento
- **Aprendizaje Visual**: Explora los modelos 3D para entender mejor la anatomía

### Para Internados y Residentes
- **Guía de Repaso Rápido**: Acceso rápido a información médica clave
- **Apoyo Clínico**: Consulta casos clínicos para referencia práctica
- **Evaluación Continua**: Mide tu progreso con exámenes temáticos

## 🎨 Interfaz de Usuario

La aplicación cuenta con un diseño intuitivo y moderno:
- Navegación por pestañas para fácil acceso
- Modo oscuro/claro para comodidad visual
- Interfaz adaptable para diferentes tamaños de pantalla
- Accesibilidad y usabilidad optimizadas

## 🔧 Configuración del Proyecto

### Estructura del Proyecto
```
lib/
├── features/           # Características principales
│   ├── auth/          # Autenticación
│   ├── home/          # Pantalla principal
│   ├── flashcard/     # Sistema de flashcards
│   ├── quizzes/       # Sistema de exámenes
│   ├── cases/         # Casos clínicos
│   └── settings/      # Configuración
├── core/              # Utilidades y configuración central
├── l10n/             # Internacionalización
└── main.dart         # Punto de entrada
```

### Variables de Entorno
Crea un archivo `.env` con las siguientes variables:
```
FIREBASE_API_KEY=tu_api_key
FIREBASE_AUTH_DOMAIN=tu_auth_domain
FIREBASE_PROJECT_ID=tu_project_id
```

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Por favor:

1. Fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/NuevaCaracteristica`)
3. Commit tus cambios (`git commit -m 'Añadir nueva característica'`)
4. Push a la rama (`git push origin feature/NuevaCaracteristica`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - consulta el archivo [LICENSE](LICENSE) para más detalles.

## 🙏 Agradecimientos

- A la comunidad médica por su valiosa retroalimentación
- A los desarrolladores de Flutter por las herramientas increíbles
- A todos los estudiantes de medicina que inspiraron esta aplicación

## 📞 Contacto

- **Email**: contacto@studymedical.com
- **Issues**: [GitHub Issues](https://github.com/tu-usuario/study_medical/issues)
- **Discusión**: [GitHub Discussions](https://github.com/tu-usuario/study_medical/discussions)

---

**Study Medical** - Tu compañero de estudio médico confiable 🩺