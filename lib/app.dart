import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_service.dart';
import 'features/settings/presentation/providers/theme_provider.dart';
import 'features/settings/presentation/providers/locale_provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_router == null) {
      final authService = context.read<AuthService>();
      _router = appRouter(authService);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    if (_router == null) {
      return const SizedBox.shrink();
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // Controlar factor de escala de texto para consistencia entre dispositivos
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
        ),
      ),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Study Medical',
        locale: localeProvider.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: LocaleProvider.supportedLocales,
        themeMode: themeProvider.themeMode,
        theme: AppTheme.light(themeProvider.colorSeed).copyWith(
          // Asegurar tamaños de fuente consistentes
          textTheme: AppTheme.light(themeProvider.colorSeed).textTheme.apply(
            fontSizeFactor: 1.0,  // Factor de escala fijo
          ),
        ),
        darkTheme: AppTheme.dark(themeProvider.colorSeed).copyWith(
          textTheme: AppTheme.dark(themeProvider.colorSeed).textTheme.apply(
            fontSizeFactor: 1.0,
          ),
        ),
        routerConfig: _router!,
      ),
    );
  }
}
