import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/models/app_language.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/main_screen.dart';

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
  /// (ใช้ pump แทน Future.delayed เพื่อให้เฟรม/กล้องยังอัปเดตระหว่างรอ)
  const stepDelay = Duration(seconds: 1);
  Future<void> delay(WidgetTester tester) => tester.pump(stepDelay);

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    expect(finder, findsWidgets);
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
    await delay(tester);
  }

  /// เลือกตัวเลือกแรกใน bottom sheet ของช่อง Select (color / style)
  Future<void> pickFirstOption(WidgetTester tester, String placeholder) async {
    final field = find.text(placeholder);
    await tester.ensureVisible(field); // เลื่อนให้ช่องอยู่ในจอก่อนแตะ
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
      await delay(tester); // รอโหลด overlay asset ด้วย
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
    await tester.enterText(find.byType(TextField), name);
    // ปิดคีย์บอร์ดก่อน ไม่งั้นมันบังช่อง Select ด้านล่าง ทำให้แตะไม่โดน
    await tester.testTextInput.receiveAction(TextInputAction.done);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await delay(tester);
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
    'camera -> save -> recommend -> try outfit -> favorite -> delete',
    (tester) async {
      final closet = ClosetRepository.instance;

      // เริ่มจากตู้ว่างเพื่อให้ผลทดสอบแน่นอน
      await tester.runAsync(() async {
        await closet.load();
        for (final item in List.of(closet.items.value)) {
          await closet.delete(item.id);
        }
      });
      expect(closet.items.value, isEmpty);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: MainScreen(
            selectedLanguage: AppLanguage.english,
            onLanguageChanged: (_) {},
          ),
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
      // Recommend ต้องมีทั้งเสื้อและกางเกง จึงถ่ายเพิ่มอีก 1 ชิ้น
      // (เลือก color/style ตัวเลือกแรกเหมือนกัน เพื่อให้จับคู่กันได้)
      await takePhotoAndSave(tester, name: 'Test Bottom', guide: 'Pants');
      expect(closet.items.value.length, 2);
      expect(find.text('Matchoose'), findsOneWidget);

      /*await tapAndSettle(tester, find.byIcon(Icons.settings_outlined));
      expect(find.text('Settings'), findsOneWidget);
      await tapAndSettle(tester, find.text('Thai'));
      expect(find.text('การตั้งค่า'), findsOneWidget);
      await tapAndSettle(tester, find.text(''));*/


      // ===== 4) Home -> Recommend =====
      await tapAndSettle(tester, find.byIcon(Icons.auto_awesome));
      expect(find.text('Recommend'), findsOneWidget);
      await tapAndSettle(tester, find.byIcon(Icons.chevron_left));

      // ===== 5) Home -> Try Outfit =====
      await tapAndSettle(tester, find.byIcon(Icons.checkroom));
      expect(find.text('Try Outfit'), findsOneWidget);

      // ===== 6) แตะรูปในแถวแรก -> Preview =====
      await tapAndSettle(tester, find.byType(PageView));
      expect(find.text('Preview Item'), findsOneWidget);

      // ===== 7) Favorite =====
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      await tapAndSettle(tester, find.byIcon(Icons.favorite_border));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(closet.items.value.where((i) => i.isFavorite).length, 1);

      // ===== 8) Delete =====
      await tapAndSettle(tester, find.byIcon(Icons.delete_outline));
      expect(find.text('Delete this item?'), findsOneWidget);
      await tapAndSettle(tester, find.text('Delete'));

      // Preview ปิดแล้ว กลับ Try Outfit
      expect(find.text('Preview Item'), findsNothing);
      expect(find.text('Try Outfit'), findsOneWidget);
      expect(closet.items.value.length, 1);

      // ===== 9) กลับ Home =====
      await tapAndSettle(tester, find.byIcon(Icons.chevron_left));
      expect(find.text('Matchoose'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
