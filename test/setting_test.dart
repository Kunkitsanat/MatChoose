// test/settings_screen_test.dart
//
// ทดสอบหน้า SettingsScreen + AppSettings แบบง่ายๆ
//   flutter test test/settings_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/models/app_language.dart';
import 'package:matchoose/screens/setting/app_settings.dart';
import 'package:matchoose/screens/setting/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _settings = AppSettings.instance;

/// แสดงหน้า Settings พร้อม localization; คืนรายการภาษาที่ถูกเลือกผ่าน callback
Future<List<AppLanguage>> _pumpSettings(
  WidgetTester tester, {
  AppLanguage selected = AppLanguage.system,
}) async {
  // จอสูงๆ เพื่อให้เห็นทุกตัวเลือกโดยไม่ต้องเลื่อน
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final changes = <AppLanguage>[];
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SettingsScreen(
          selectedLanguage: selected,
          onLanguageChanged: changes.add,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return changes;
}

AppLocalizations _l10n(WidgetTester tester) => AppLocalizations.of(tester.element(find.byType(SettingsScreen)))!;

void main() {
  // singleton: รีเซ็ตค่าก่อนทุกเทส
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await _settings.setFontSize(FontSizeOption.system);
    await _settings.setLocale(null);
  });

  group('SettingsScreen', () {
    testWidgets('แสดงหัวข้อ, ตัวเลือกภาษา 3 ตัว และขนาดตัวอักษร 5 ตัว',
        (tester) async {
      await _pumpSettings(tester);
      final l10n = _l10n(tester);

      expect(find.text(l10n.settings), findsOneWidget);
      expect(find.text(l10n.language), findsOneWidget);
      expect(find.text(l10n.languageSystem), findsOneWidget);
      expect(find.text(l10n.languageThai), findsOneWidget);
      expect(find.text(l10n.languageEnglish), findsOneWidget);

      expect(find.text(l10n.fontSize), findsOneWidget);
      expect(find.byType(RadioListTile<FontSizeOption>), findsNWidgets(5));
    });

    testWidgets('กด English / ภาษาไทย => เรียก onLanguageChanged ด้วยค่าที่เลือก',
        (tester) async {
      final changes = await _pumpSettings(tester);
      final l10n = _l10n(tester);

      await tester.tap(find.text(l10n.languageEnglish));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.languageThai));
      await tester.pumpAndSettle();

      expect(changes, [AppLanguage.english, AppLanguage.thai]);
    });

    testWidgets('ภาษาที่ส่งเข้ามา (selectedLanguage) ถูกแสดงเป็นตัวที่เลือกอยู่',
        (tester) async {
      await _pumpSettings(tester, selected: AppLanguage.thai);

      final group = tester.widget<RadioGroup<AppLanguage>>(
        find.byType(RadioGroup<AppLanguage>),
      );
      expect(group.groupValue, AppLanguage.thai);
    });

    testWidgets('กดขนาดตัวอักษร Large => AppSettings เปลี่ยนทันที '
        'และบันทึกลงเครื่อง', (tester) async {
      await _pumpSettings(tester);
      final l10n = _l10n(tester);

      await tester.tap(find.text(l10n.fontSizeLarge));
      await tester.pumpAndSettle();

      expect(_settings.fontSize, FontSizeOption.large);
      final group = tester.widget<RadioGroup<FontSizeOption>>(
        find.byType(RadioGroup<FontSizeOption>),
      );
      expect(group.groupValue, FontSizeOption.large);

      final prefs = await tester.runAsync(SharedPreferences.getInstance);
      expect(prefs!.getString('settings.fontSize'), 'large');
    });
  });

  group('AppSettings', () {
    test('setLocale(th) => จำภาษาไว้และบันทึก; setLocale(null) => ลบค่า',
        () async {
      await _settings.setLocale(const Locale('th'));
      expect(_settings.locale, const Locale('th'));
      expect((await SharedPreferences.getInstance()).getString('settings.locale'),
          'th');

      await _settings.setLocale(null);
      expect(_settings.locale, isNull);
      expect((await SharedPreferences.getInstance()).containsKey('settings.locale'),
          isFalse);
    });

    test('load() => อ่านขนาดตัวอักษรและภาษาที่เคยบันทึกไว้', () async {
      SharedPreferences.setMockInitialValues({
        'settings.fontSize': 'extraLarge',
        'settings.locale': 'th',
      });

      await _settings.load();

      expect(_settings.fontSize, FontSizeOption.extraLarge);
      expect(_settings.locale, const Locale('th'));
    });

    test('resolveTextScaler: เลือกขนาดเอง => ใช้ค่าคงที่ ไม่สนระบบ',
        () async {
      await _settings.setFontSize(FontSizeOption.large);

      final scaler = _settings.resolveTextScaler(TextScaler.linear(2.0));

      expect(scaler.scale(10), closeTo(11.5, 0.001)); // 1.15
    });

    test('resolveTextScaler: ตามระบบ => จำกัดช่วง 0.9 - 1.3', () {
      expect(
        _settings.resolveTextScaler(TextScaler.linear(2.0)).scale(10),
        closeTo(13, 0.001),
      );
      expect(
        _settings.resolveTextScaler(TextScaler.linear(0.5)).scale(10),
        closeTo(9, 0.001),
      );
    });
  });
}