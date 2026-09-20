import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/main_screen.dart';

void main() {
  runApp(const MatchooseApp());
}

class MatchooseApp extends StatelessWidget {
  const MatchooseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matchoose',

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

      home: MainScreen(),
    );
  }
}