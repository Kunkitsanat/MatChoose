import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/models/app_language.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/outfit_repository.dart';
import 'package:matchoose/screens/main_screen.dart';
import 'package:matchoose/screens/setting/app_settings.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------

  /// pump ไปเรื่อยๆ จนกว่าจะเจอ [finder] (ใช้แทน pumpAndSettle
  /// เพราะหน้ากล้องมี animation วนไม่รู้จบ ทำให้ settle ไม่ได้)
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
    String? reason,
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail(reason ?? 'Timed out waiting for $finder');
  }

  /// หน่วงทุกขั้นตอนประมาณ 1 วินาที เพื่อให้ดูการทำงานทัน
  const stepDelay = Duration(seconds: 1);
  Future<void> delay(WidgetTester tester) => tester.pump(stepDelay);

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    expect(finder, findsWidgets);
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
    await delay(tester);
  }

  /// พิมพ์ข้อความลงช่อง TextField แล้วปิดคีย์บอร์ด
  Future<void> typeText(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await delay(tester);
  }

  /// เลือกตัวเลือกแรกใน bottom sheet ของช่อง Select (color / style)
  Future<void> pickFirstOption(WidgetTester tester, String placeholder) async {
    final field = find.text(placeholder);
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tapAndSettle(tester, field);
    await tapAndSettle(tester, find.byType(ListTile));
  }

  /// ถ่ายรูปด้วยกล้องจริงที่หน้า Align แล้วบันทึกลงตู้ด้วยชื่อ [name]
  /// guide: ถ้าระบุ (เช่น 'Pants') จะสลับ guide ผ่านเมนู Elements ก่อนถ่าย
  Future<void> takePhotoAndSave(
    WidgetTester tester, {
    required String name,
    String? guide,
  }) async {
    // Home tab -> Add tab
    await tapAndSettle(tester, find.byIcon(Icons.add));
    await tapAndSettle(tester, find.byKey(const Key('take_photo_button')));

    // รอกล้องเปิดจริง
    await pumpUntil(
      tester,
      find.byType(CameraPreview),
      reason: 'Camera preview did not appear (ให้สิทธิ์กล้องแล้วหรือยัง?)',
    );
    await delay(tester);

    if (guide != null) {
      await tester.tap(find.byKey(const Key('elements_button')));
      await delay(tester);
      await tester.tap(find.text(guide));
      await delay(tester);
    }

    // ถ่ายรูป (crop/mask ทำใน isolate ใช้เวลาสักพัก)
    await tester.tap(find.byKey(const Key('shutter_button')));
    await pumpUntil(
      tester,
      find.text('Save Item'),
      timeout: const Duration(seconds: 60),
      reason: 'Did not reach Save Item screen after taking photo',
    );
    await tester.pumpAndSettle();
    await delay(tester);

    // กรอกข้อมูล (category เดาจาก guide ให้อัตโนมัติ)
    await typeText(tester, name);
    await pickFirstOption(tester, 'Select color');
    await pickFirstOption(tester, 'Select style');

    await tapAndSettle(tester, find.text('Add to Closet'));

    // Save pop(true) -> Align pop(true) -> กลับหน้า Main
    await pumpUntil(tester, find.byType(NavigationBar));
    await tester.pumpAndSettle();
    await delay(tester);

    // กลับ Home tab
    await tapAndSettle(tester, find.byIcon(Icons.inventory_2_outlined));
  }

  // ------------------------------------------------------------
  // Test
  // ------------------------------------------------------------

  testWidgets(
    'camera -> recommend -> save outfit -> my outfits -> try outfit -> '
    'favorite -> delete -> search -> settings',
    (tester) async {
      final closet = ClosetRepository.instance;
      final outfitRepo = OutfitRepository.instance;

      // เริ่มจากตู้ว่างและไม่มีชุดค้างอยู่ เพื่อให้ผลทดสอบแน่นอน
      // (ถ้ามีชุดซ้ำ add() จะคืน null แล้วกดบันทึกไม่ขึ้น)
      await tester.runAsync(() async {
        await closet.load();
        for (final item in List.of(closet.items.value)) {
          await closet.delete(item.id);
        }

        await outfitRepo.load();
        for (final o in List.of(outfitRepo.outfits.value)) {
          await outfitRepo.delete(o.id);
        }
      });
      expect(closet.items.value, isEmpty);
      expect(outfitRepo.outfits.value, isEmpty);

      AppLanguage? changedTo; // เก็บค่าที่ถูกเรียกจาก onLanguageChanged
      AppLanguage currentLanguage = AppLanguage.english;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale(currentLanguage == AppLanguage.thai ? 'th' : 'en'),
              home: MainScreen(
                selectedLanguage: currentLanguage,
                onLanguageChanged: (l) {
                  changedTo = l;
                  setState(() {
                    currentLanguage = l;
                  });
                },
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      await delay(tester);

      // ===== 1) Home (ว่าง) =====
      expect(find.text('Matchoose'), findsOneWidget);

      // ===== 2) ถ่ายเสื้อ (T-Shirt = tops) =====
      await takePhotoAndSave(tester, name: 'Test Top');
      expect(closet.items.value.length, 1);

      // ===== 3) ถ่ายกางเกง (Pants = bottoms) =====
      await takePhotoAndSave(tester, name: 'Test Bottom', guide: 'Pants');
      expect(closet.items.value.length, 2);
      expect(find.text('Matchoose'), findsOneWidget);

      // ===== 4) Home -> Recommend (แค่เปิดดู แล้วกลับ) =====
      await tapAndSettle(tester, find.byIcon(Icons.auto_awesome));
      expect(find.text('Recommend'), findsOneWidget);
      await tapAndSettle(tester, find.byIcon(Icons.chevron_left));

      // ===== 5) Home -> Try Outfit -> Save Outfit =====
      await tapAndSettle(tester, find.byIcon(Icons.checkroom));
      expect(find.text('Try Outfit'), findsOneWidget);

      await tapAndSettle(tester, find.byKey(const Key('save_outfit_button')));

      // เช็กว่าบันทึกลง repository แล้วจริง ก่อนไปหน้า My Outfits
      expect(outfitRepo.outfits.value.length, 1);
      final savedOutfit = outfitRepo.outfits.value.first;

      // กลับ Home
      await tapAndSettle(tester, find.byIcon(Icons.chevron_left));
      expect(find.text('Matchoose'), findsOneWidget);

      // ===== 6) My Outfits =====
      await tapAndSettle(tester, find.byIcon(Icons.bookmark_border));
      expect(find.text('My Outfits'), findsOneWidget);
      expect(find.text(savedOutfit.name), findsOneWidget);

      // แตะรูปในชุด -> Preview -> กลับ
      await tapAndSettle(tester, find.byType(Image).first);
      expect(find.text('Preview Item'), findsOneWidget);
      await tapAndSettle(tester, find.byIcon(Icons.chevron_left));

      // Rename
      await tapAndSettle(tester, find.byIcon(Icons.more_vert));
      await tapAndSettle(tester, find.text('Rename'));
      await tester.enterText(find.byType(TextField), 'Renamed Outfit');
      await tapAndSettle(tester, find.text('Save'));
      expect(find.text('Renamed Outfit'), findsOneWidget);

      // Delete
      await tapAndSettle(tester, find.byIcon(Icons.more_vert));
      await tapAndSettle(tester, find.text('Delete')); // เมนู popup
      await tapAndSettle(
        tester,
        find.widgetWithText(TextButton, 'Delete'), // ปุ่มใน dialog
      );
      expect(find.text('Renamed Outfit'), findsNothing);
      expect(outfitRepo.outfits.value, isEmpty);

      // กลับ Home tab
      await tapAndSettle(tester, find.byIcon(Icons.inventory_2_outlined));

      // ===== 7) Home -> Try Outfit -> Preview =====
      await tapAndSettle(tester, find.byIcon(Icons.checkroom));
      expect(find.text('Try Outfit'), findsOneWidget);

      await tapAndSettle(tester, find.byType(PageView));
      expect(find.text('Preview Item'), findsOneWidget);

      // ===== 8) Favorite =====
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      await tapAndSettle(tester, find.byIcon(Icons.favorite_border));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(closet.items.value.where((i) => i.isFavorite).length, 1);

      // ===== 9) Delete item (ทำหลังทดสอบ My Outfits แล้ว) =====
      await tapAndSettle(tester, find.byIcon(Icons.delete_outline));
      expect(find.text('Delete this item?'), findsOneWidget);
      await tapAndSettle(tester, find.text('Delete'));

      // Preview ปิดแล้ว กลับ Try Outfit
      expect(find.text('Preview Item'), findsNothing);
      expect(find.text('Try Outfit'), findsOneWidget);
      expect(closet.items.value.length, 1);

      // กลับ Home
      await tapAndSettle(tester, find.byIcon(Icons.chevron_left));
      expect(find.text('Matchoose'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);

      // ===== 10) Search (ใช้ชื่อชิ้นที่เหลืออยู่) =====
      final target = closet.items.value.first;

      await tapAndSettle(tester, find.byIcon(Icons.search));
      await typeText(tester, target.name);
      await tapAndSettle(tester, find.byKey(const Key('search_button')));
      expect(find.byKey(Key('search_item_${target.id}')), findsOneWidget);

      // แตะการ์ด -> Preview -> กลับ
      await tapAndSettle(tester, find.byKey(Key('search_item_${target.id}')));
      expect(find.text('Preview Item'), findsOneWidget);
      await tapAndSettle(tester, find.byIcon(Icons.chevron_left)); // กลับจาก PreviewItemScreen

      // ย้อนกลับออกจากหน้า SearchResultScreen ไปยังหน้า Main
      await tapAndSettle(tester, find.byIcon(Icons.chevron_left)); // กลับจาก SearchResultScreen

      // ===== 11) Settings =====
      await tapAndSettle(tester, find.byIcon(Icons.settings_outlined));
      expect(find.text('Settings'), findsOneWidget);

      // ภาษา: เลือกตัวที่ 3 (Thai) แล้วเช็กว่า callback ถูกเรียก
      await tapAndSettle(
        tester,
        find.byType(RadioListTile<AppLanguage>).at(2),
      );
      expect(changedTo, AppLanguage.thai);

      // ขนาดตัวอักษร: เลือกตัวที่ 4 (large)
      final fontTile = find.byType(RadioListTile<FontSizeOption>).at(3);
      await tester.ensureVisible(fontTile);
      await tester.pumpAndSettle();
      await tapAndSettle(tester, fontTile);
      expect(AppSettings.instance.fontSize, FontSizeOption.large);

      // คืนค่าเดิม ไม่ให้ค้างไปรอบถัดไป
      await tester.runAsync(
        () => AppSettings.instance.setFontSize(FontSizeOption.system),
      );
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}