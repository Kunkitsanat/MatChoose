import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ขนาดตัวอักษรที่ผู้ใช้เลือกได้
///
/// [system] = ตามขนาดฟอนต์ของเครื่อง (ค่าเริ่มต้น)
/// ตัวเลือกอื่น = ใช้สัดส่วนคงที่ ไม่สนค่าของระบบ
enum FontSizeOption {
  system(null),
  small(0.85),
  normal(1.0),
  large(1.15),
  extraLarge(1.3);

  const FontSizeOption(this.scale);

  /// null = ตามระบบ
  final double? scale;
}

/// ค่าตั้งค่าของแอป (ขนาดตัวอักษร + ภาษา) เก็บในเครื่อง
///
/// ใช้ร่วมกับ MaterialApp ผ่าน ListenableBuilder (ดูตัวอย่างใน main.dart)
class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _kFontSize = 'settings.fontSize';
  static const _kLocale = 'settings.locale';

  FontSizeOption _fontSize = FontSizeOption.system;

  /// null = ตามภาษาของเครื่อง
  Locale? _locale;

  FontSizeOption get fontSize => _fontSize;
  Locale? get locale => _locale;

  /// เรียกใน main() ก่อน runApp เพื่อไม่ให้ขนาด/ภาษากะพริบตอนเปิดแอป
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final fontName = prefs.getString(_kFontSize);
      _fontSize = FontSizeOption.values.firstWhere(
        (o) => o.name == fontName,
        orElse: () => FontSizeOption.system,
      );

      final lang = prefs.getString(_kLocale);
      _locale = lang == null ? null : Locale(lang);
    } catch (e) {
      debugPrint('Load settings error: $e'); // ใช้ค่าเริ่มต้นต่อ
    }
  }

  Future<void> setFontSize(FontSizeOption option) async {
    if (option == _fontSize) return;
    _fontSize = option;
    notifyListeners(); // UI เปลี่ยนทันที ไม่ต้องรอเขียนไฟล์

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontSize, option.name);
  }

  /// [locale] = null คือกลับไปตามภาษาของเครื่อง
  Future<void> setLocale(Locale? locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kLocale);
    } else {
      await prefs.setString(_kLocale, locale.languageCode);
    }
  }

  /// ตัวคูณขนาดตัวอักษรที่จะใช้จริง ใช้ใน MaterialApp.builder
  TextScaler resolveTextScaler(TextScaler systemScaler) {
    final fixed = _fontSize.scale;
    if (fixed != null) return TextScaler.linear(fixed);

    // ตามระบบ แต่จำกัดช่วงไม่ให้ layout พัง
    return systemScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.3);
  }
}