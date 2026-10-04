import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/app_localizations.dart';

import 'screens/main_screen.dart';
import 'package:matchoose/models/app_language.dart';

void main() {
  runApp(const MatchooseApp());
}

class MatchooseApp extends StatefulWidget {
  const MatchooseApp({super.key});

  @override
  State<MatchooseApp> createState() => _MatchooseAppState();
}

class _MatchooseAppState extends State<MatchooseApp> {
  AppLanguage _language = AppLanguage.system;

  Locale? _getLocale() {
    switch (_language) {
      case AppLanguage.system:
        return null;

      case AppLanguage.english:
        return const Locale('en');

      case AppLanguage.thai:
        return const Locale('th');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matchoose',

      localizationsDelegates:
        AppLocalizations.localizationsDelegates,

      supportedLocales:
        AppLocalizations.supportedLocales,

      locale: _getLocale(),

      theme: ThemeData(
        textTheme: GoogleFonts.playfairDisplayTextTheme(),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.brown.shade100,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
        ),
        useMaterial3: true,
      ),

      home: MainScreen(
        selectedLanguage: _language,
        onLanguageChanged: (value) {
          setState(() {
            _language = value;
          });
        },
      ),
    );
  }
}