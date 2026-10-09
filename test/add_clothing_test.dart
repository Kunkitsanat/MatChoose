import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/screens/add/add_clothing_screen.dart';
import 'package:matchoose/screens/main_screen.dart';
import 'package:matchoose/models/app_language.dart';

/// PNG ขนาด 1x1 สำหรับใช้เป็น "รูปที่เลือกจาก gallery"
final _tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

/// MaterialApp ที่ใส่ localization ให้ครบ
/// (หน้า Home / AddClothing ใช้ AppLocalizations.of(context)! ถ้าไม่ใส่จะได้ null
///  แล้วเกิด "Null check operator used on a null value")
Widget _app(Widget home) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: home,
    );

/// จำลอง image_picker: เมื่อแอปเรียก pickImage จะได้ [result] กลับไป
/// (null = ผู้ใช้กดยกเลิก)
void _mockImagePicker(String? result) {
  const channel = MethodChannel('plugins.flutter.io/image_picker');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    if (call.method == 'pickImage') return result;
    return null;
  });
  addTearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
}

void main() {
  testWidgets('Go to Add Clothing Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      _app(
        MainScreen(
          selectedLanguage: AppLanguage.system,
          onLanguageChanged: (value) {},
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add Clothing'), findsOneWidget);
  });

  testWidgets('Add Clothing Screen has a title and a button', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(_app(const AddClothingScreen()));

    // Verify that the title is displayed.
    expect(find.text('Add Clothing'), findsOneWidget);

    // Verify that the button is displayed.
    expect(find.byKey(const Key('from_gallery_button')), findsOneWidget);
    expect(find.byKey(const Key('take_photo_button')), findsOneWidget);
  });

  testWidgets('Pressing the button navigates to AlignItemsScreen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(_app(const AddClothingScreen()));

    // Tap the button.
    await tester.tap(find.byKey(const Key('take_photo_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that we navigated to the AlignItemsScreen.
    expect(find.text('Align Outfit'), findsOneWidget);
  });

  testWidgets('Pressing the gallery button and picking a photo navigates to '
      'AlignItemsScreen in gallery mode', (WidgetTester tester) async {
    // เตรียมรูปจำลอง + จำลอง image_picker ให้เลือกรูปนี้
    final tmp = Directory.systemTemp.createTempSync('add_clothing_test_');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final photo = File('${tmp.path}/photo.png')..writeAsBytesSync(_tinyPng);
    _mockImagePicker(photo.path);

    await tester.pumpWidget(_app(const AddClothingScreen()));

    await tester.tap(find.byKey(const Key('from_gallery_button')));
    await tester.pump();
    // รอ I/O จริงช่วงสั้นๆ (อ่านไฟล์/โหลดรูป) แล้ว pump ให้ route เดิน
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(milliseconds: 500));

    // โหมด gallery ใช้หัวข้อ "Adjust Photo" (โหมดกล้องคือ "Align Outfit")
    expect(find.text('Adjust Photo'), findsOneWidget);
  });

  testWidgets('Pressing the gallery button but cancelling stays on '
      'Add Clothing Screen', (WidgetTester tester) async {
    _mockImagePicker(null); // ผู้ใช้กดยกเลิก ไม่ได้เลือกรูป

    await tester.pumpWidget(_app(const AddClothingScreen()));

    await tester.tap(find.byKey(const Key('from_gallery_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Add Clothing'), findsOneWidget);
    expect(find.text('Adjust Photo'), findsNothing);
  });
}