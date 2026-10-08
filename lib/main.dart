import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'l10n/app_localizations.dart';

import 'screens/main_screen.dart';
import 'package:matchoose/models/app_language.dart';
import 'package:matchoose/screens/setting/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // โหลดค่าที่ผู้ใช้เคยตั้งไว้ (ขนาดตัวอักษร, ภาษา) ก่อนเปิดแอป จะได้ไม่กะพริบ
  await AppSettings.instance.load();

  runApp(const MatchooseApp());
}

class MatchooseApp extends StatefulWidget {
  const MatchooseApp({super.key});

  @override
  State<MatchooseApp> createState() => _MatchooseAppState();
}

class _MatchooseAppState extends State<MatchooseApp> {
  // เริ่มจากภาษาที่บันทึกไว้ (ถ้าไม่เคยเลือก = ตามระบบ)
  late AppLanguage _language = _languageFrom(AppSettings.instance.locale);

  static AppLanguage _languageFrom(Locale? locale) {
    switch (locale?.languageCode) {
      case 'en':
        return AppLanguage.english;
      case 'th':
        return AppLanguage.thai;
      default:
        return AppLanguage.system;
    }
  }

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

  void _onLanguageChanged(AppLanguage value) {
    setState(() {
      _language = value;
    });

    // บันทึกลงเครื่อง เพื่อให้เปิดแอปครั้งหน้ายังเป็นภาษาเดิม
    AppSettings.instance.setLocale(_getLocale());
  }

  @override
  Widget build(BuildContext context) {
    // ฟังค่าตั้งค่า (ขนาดตัวอักษร) เพื่อให้ทั้งแอปปรับตามทันที
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final settings = AppSettings.instance;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Matchoose',

          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
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

          // ปรับขนาดตัวอักษรทั้งแอปที่จุดเดียว (ค่าเริ่มต้น = ตามขนาดของระบบ)
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: settings.resolveTextScaler(mq.textScaler),
              ),
              child: child!,
            );
          },

          home: MainScreen(
            selectedLanguage: _language,
            onLanguageChanged: _onLanguageChanged,
          ),
        );
      },
    );
  }
}