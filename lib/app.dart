import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Study Medical',
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleProvider.supportedLocales,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light(themeProvider.colorSeed),
      darkTheme: AppTheme.dark(themeProvider.colorSeed),
      routerConfig: _router!,
    );
  }
}
