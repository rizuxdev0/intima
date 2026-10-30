import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../features/settings/providers/preferences_provider.dart';
import 'localization/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Application racine INTIMA.
class IntimaApp extends ConsumerWidget {
  const IntimaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final prefsAsync = ref.watch(preferencesProvider);

    final prefs = prefsAsync.valueOrNull;
    final locale = prefs?.locale != null ? Locale(prefs!.locale) : const Locale('fr');
    final themeMode = prefs?.themeMode ?? ThemeMode.system;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}

