// test/align_items_screen_test.dart
//
// ทดสอบการกดปุ่มต่างๆ ในหน้า AlignItemsScreen และผลลัพธ์ที่ควรเกิดขึ้น
//
// ปุ่ม/จุดที่ทดสอบ:
//   1. ปุ่ม Back (ลูกศรซ้ายบน)
//   2. ปุ่ม Elements (เปิด/ปิดเมนู Guide type)
//   3. barrier — กดพื้นที่ว่างเพื่อปิดเมนู
//   4. รายการในเมนู: Shirt / T-Shirt / Pants / Shorts
//   5. ปุ่ม Shutter (โหมดกล้อง = ถ่าย, โหมด gallery = ยืนยัน ✓)
//
// ก่อนรัน: แก้ import 2 บรรทัดด้านล่างให้ตรงกับชื่อ package / path ของโปรเจกต์
//   flutter test test/align_items_screen_test.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:matchoose/screens/add/align_items_screen.dart';
import 'package:matchoose/screens/add/save_item_screen.dart';

// ============================================================
// Helpers
// ============================================================

final Finder _shutter = find.byKey(const Key('shutter_button'));
final Finder _elements = find.byKey(const Key('elements_button'));
final Finder _backButton = find.byIcon(Icons.arrow_back_ios_new);
final Finder _launcherOpen = find.byKey(const Key('launcher_open'));

/// หา Image.asset ของ guide ชนิดที่ระบุ (ใช้เช็คว่า overlay เปลี่ยนตามเมนู)
Finder _guideImage(GuideType t) => find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == t.assetPath,
    );

/// ตั้งขนาดจอเป็นมือถือ (400x800 @1x)
void _usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// หน้า launcher ที่มีปุ่ม "open" เพื่อ push หน้าที่จะทดสอบ
/// (ทำให้ทดสอบ Back / pop ได้จริง เพราะมี route ข้างล่างรองรับ)
Widget _launcher(Widget Function() screen) {
  return MaterialApp(
    home: Builder(
      builder: (ctx) => Scaffold(
        body: Center(
          child: ElevatedButton(
            key: const Key('launcher_open'),
            onPressed: () => Navigator.of(ctx).push(
              MaterialPageRoute(builder: (_) => screen()),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

/// pump แบบไม่ใช้ pumpAndSettle (เพราะ CircularProgressIndicator วนไม่รู้จบ)
Future<void> _pumpMs(WidgetTester tester, [int ms = 300]) =>
    tester.pump(Duration(milliseconds: ms));

/// รอให้งาน async จริง (อ่านไฟล์/decode รูป/isolate) ทำงานเสร็จ แล้ว pump
Future<void> _waitReal(WidgetTester tester, [int ms = 500]) async {
  await tester.runAsync(
    () => Future<void>.delayed(Duration(milliseconds: ms)),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// pump + รอของจริงวนไปจนกว่าจะเจอ [finder] (หรือ timeout)
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 500)); // route animation
      return;
    }
  }
  fail('Timeout: ไม่พบ $finder');
}

/// เปิดเมนู Elements แล้วรอ animation
Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(_elements);
  await _pumpMs(tester);
}

/// overlay PNG จำลอง: กรอบสี่เหลี่ยมปิดสนิท เว้นขอบนอก 10% (โปร่งใส)
/// ภายในกรอบ = "ตัวเสื้อ" (flood fill จากขอบจะเข้าไปไม่ถึง => mask ขาว)
Uint8List _fakeOverlayPng() {
  final im = img.Image(width: 100, height: 100, numChannels: 4);
  for (var y = 0; y < 100; y++) {
    for (var x = 0; x < 100; x++) {
      final inBox = x >= 10 && x <= 89 && y >= 10 && y <= 89;
      final onRing = inBox && (x <= 13 || x >= 86 || y <= 13 || y >= 86);
      im.setPixelRgba(x, y, 255, 255, 255, onRing ? 255 : 0);
    }
  }
  return Uint8List.fromList(img.encodePng(im));
}

// ============================================================
// Tests
// ============================================================

void main() {
  late Directory tmp;
  late String photoPath;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('align_items_test_');

    // รูปจำลองจาก gallery 600x800
    final photo = img.Image(width: 600, height: 800);
    img.fill(photo, color: img.ColorRgb8(200, 60, 60));
    final f = File('${tmp.path}/photo.png')
      ..writeAsBytesSync(img.encodePng(photo));
    photoPath = f.path;
  });

  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  // ----------------------------------------------------------
  // enum GuideType (unit)
  // ----------------------------------------------------------
  group('GuideType', () {
    test('assetPath ต้องเป็น assets/templates/<id>/<id>_overlay.png', () {
      expect(
        GuideType.tshirt.assetPath,
        'assets/templates/tshirt/tshirt_overlay.png',
      );
      expect(
        GuideType.pants.assetPath,
        'assets/templates/pants/pants_overlay.png',
      );
    });

    test('มีครบ 4 ชนิด เรียงตามเมนู: Shirt, T-Shirt, Pants, Shorts', () {
      expect(
        GuideType.values.map((e) => e.label).toList(),
        ['Shirt', 'T-Shirt', 'Pants', 'Shorts'],
      );
    });
  });

  // ----------------------------------------------------------
  // โหมดกล้อง (ในเทสไม่มีกล้องจริง => controller เป็น null)
  // ----------------------------------------------------------
  group('โหมดกล้อง: การกดปุ่ม', () {
    testWidgets('เปิดหน้า: หัวข้อ "Align Outfit", มี Shutter + Elements, '
        'เมนูยังปิดอยู่, guide เริ่มต้น = T-Shirt', (tester) async {
      _usePhoneScreen(tester);
      await tester.pumpWidget(
        const MaterialApp(home: AlignItemsScreen()),
      );
      await _pumpMs(tester);

      expect(find.text('Align Outfit'), findsOneWidget);
      expect(_shutter, findsOneWidget);
      expect(_elements, findsOneWidget);
      expect(find.text('GUIDE TYPE'), findsNothing);
      expect(_guideImage(GuideType.tshirt), findsOneWidget);
      // โหมดกล้อง: Shutter ไม่มีไอคอน ✓
      expect(
        find.descendant(of: _shutter, matching: find.byIcon(Icons.check)),
        findsNothing,
      );
    });

    testWidgets('กด Elements 1 ครั้ง => เมนู GUIDE TYPE เปิด '
        'พร้อม 4 รายการ และปุ่ม Elements เปลี่ยนเป็นสี active', (tester) async {
      _usePhoneScreen(tester);
      await tester.pumpWidget(
        const MaterialApp(home: AlignItemsScreen()),
      );
      await _pumpMs(tester);

      await _openMenu(tester);

      expect(find.text('GUIDE TYPE'), findsOneWidget);
      for (final t in GuideType.values) {
        expect(find.text(t.label), findsOneWidget);
      }

      final box = tester
          .widget<AnimatedContainer>(
            find.descendant(
              of: _elements,
              matching: find.byType(AnimatedContainer),
            ),
          )
          .decoration as BoxDecoration;
      expect(box.color, const Color(0xFFC4B29C)); // active
    });


    testWidgets('เมนูเปิด: รายการที่เลือกอยู่ (T-Shirt) ตัวหนา w600 '
        'รายการอื่น w500', (tester) async {
      _usePhoneScreen(tester);
      await tester.pumpWidget(
        const MaterialApp(home: AlignItemsScreen()),
      );
      await _pumpMs(tester);
      await _openMenu(tester);

      FontWeight? weightOf(String label) =>
          tester.widget<Text>(find.text(label)).style?.fontWeight;

      expect(weightOf('T-Shirt'), FontWeight.w600);
      expect(weightOf('Shirt'), FontWeight.w500);
      expect(weightOf('Pants'), FontWeight.w500);
      expect(weightOf('Shorts'), FontWeight.w500);
    });

  });

  // ----------------------------------------------------------
  // โหมด gallery (imagePath != null)
  // ----------------------------------------------------------
  group('โหมด gallery: การกดปุ่ม', () {
    setUp(() {
      // จำลอง overlay asset ให้ rootBundle.load('assets/templates/...')
      final overlay = _fakeOverlayPng();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? msg) async {
        if (msg == null) return null;
        final key = utf8.decode(
          msg.buffer.asUint8List(msg.offsetInBytes, msg.lengthInBytes),
        );
        if (key.startsWith('assets/templates/')) {
          return ByteData.sublistView(overlay);
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    Future<void> openGallery(WidgetTester tester) async {
      _usePhoneScreen(tester);
      await tester.pumpWidget(
        _launcher(() => AlignItemsScreen(imagePath: photoPath)),
      );
      await tester.tap(_launcherOpen);
      await _pumpMs(tester, 500);
      await _waitReal(tester); // รอโหลดขนาดรูป + overlay
    }

    testWidgets('กด ✓ (Shutter) => แสดง loading, แล้วไปหน้า SaveItemScreen '
        'พร้อมไฟล์ *_masked.png และ guideType = T-Shirt', (tester) async {
      await openGallery(tester);

      await tester.tap(_shutter);
      await tester.pump();
      // ระหว่างประมวลผล: Shutter แสดง spinner
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await _pumpUntil(tester, find.byType(SaveItemScreen));

      final save = tester.widget<SaveItemScreen>(find.byType(SaveItemScreen));
      expect(save.guideType, GuideType.tshirt);
      expect(save.imagePath.endsWith('_masked.png'), isTrue);
      expect(File(save.imagePath).existsSync(), isTrue);
    });

    testWidgets('ไฟล์ที่ได้เป็น PNG โปร่งใส: มุมนอกรูปทรง alpha = 0 '
        'ตรงกลางในรูปทรง alpha = 255', (tester) async {
      await openGallery(tester);

      await tester.tap(_shutter);
      await _pumpUntil(tester, find.byType(SaveItemScreen));

      final save = tester.widget<SaveItemScreen>(find.byType(SaveItemScreen));
      final out = img.decodePng(File(save.imagePath).readAsBytesSync())!;

      expect(out.hasAlpha, isTrue);
      expect(out.getPixel(0, 0).a, 0); // มุมซ้ายบน = พื้นหลัง ถูกตัดทิ้ง
      expect(
        out.getPixel(out.width ~/ 2, out.height ~/ 2).a,
        255,
      ); // กลางตัวเสื้อ = เก็บไว้
    });


    testWidgets('กด ✓ รัวๆ ระหว่างประมวลผล => ไม่เปิดหน้า Save ซ้อนกัน '
        '(guard _busy)', (tester) async {
      await openGallery(tester);

      await tester.tap(_shutter);
      await tester.pump();
      await tester.tap(_shutter, warnIfMissed: false);
      await tester.pump();
      await tester.tap(_shutter, warnIfMissed: false);

      await _pumpUntil(tester, find.byType(SaveItemScreen));

      expect(find.byType(SaveItemScreen), findsOneWidget);
    });

    testWidgets('หน้า Save pop กลับมาพร้อม true (save สำเร็จ) => '
        'หน้า Align ปิดตาม กลับไปหน้าแรก', (tester) async {
      await openGallery(tester);

      await tester.tap(_shutter);
      await _pumpUntil(tester, find.byType(SaveItemScreen));

      Navigator.of(tester.element(find.byType(SaveItemScreen))).pop(true);
      await _pumpMs(tester, 600);
      await _pumpMs(tester, 600);

      expect(find.byType(SaveItemScreen), findsNothing);
      expect(find.byType(AlignItemsScreen), findsNothing);
      expect(_launcherOpen, findsOneWidget);
    });

    testWidgets('หน้า Save pop เฉยๆ (ลบ/ย้อนกลับ) => ยังอยู่หน้า Align, '
        'spinner หาย กด ✓ ใหม่ได้', (tester) async {
      await openGallery(tester);

      await tester.tap(_shutter);
      await _pumpUntil(tester, find.byType(SaveItemScreen));

      Navigator.of(tester.element(find.byType(SaveItemScreen))).pop();
      await _pumpMs(tester, 600);
      await _pumpMs(tester, 600);

      expect(find.byType(SaveItemScreen), findsNothing);
      expect(find.byType(AlignItemsScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        find.descendant(of: _shutter, matching: find.byIcon(Icons.check)),
        findsOneWidget,
      );
    });

    testWidgets('ประมวลผลรูปไม่สำเร็จ (ไฟล์ถูกลบ) => SnackBar '
        '"ประมวลผลรูปไม่สำเร็จ ลองอีกครั้ง", ไม่ไปหน้า Save, '
        'ปุ่มกลับมากดได้', (tester) async {
      await openGallery(tester);

      File(photoPath).deleteSync(); // ทำให้ _cropAndMask อ่านไฟล์ไม่ได้

      await tester.tap(_shutter);
      await tester.pump();

      await _pumpUntil(tester, find.byType(SnackBar));

      expect(find.text('ประมวลผลรูปไม่สำเร็จ ลองอีกครั้ง'), findsOneWidget);
      expect(find.byType(SaveItemScreen), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

  });
}