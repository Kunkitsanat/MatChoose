// test/save_item_screen_test.dart
//
// ทดสอบหน้า SaveItemScreen แบบง่ายๆ (ใช้ helpers/test_env.dart ร่วมกับเทสหน้าอื่น)
//   flutter test test/save_item_screen_test.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/align_items_screen.dart' show GuideType;
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/add/save_item_screen.dart';

import 'test_env.dart';

final _repo = ClosetRepository.instance;
final _addButton = find.widgetWithText(ElevatedButton, 'Add to Closet');

bool _addEnabled(WidgetTester tester) =>
    tester.widget<ElevatedButton>(_addButton).onPressed != null;

/// เลือกค่าจาก dropdown: 0 = Category, 1 = Color, 2 = Style
Future<void> _pick(WidgetTester tester, int field, String label) async {
  final arrow = find.byIcon(Icons.keyboard_arrow_down).at(field);
  await tester.ensureVisible(arrow);
  await tester.pumpAndSettle();
  await tester.tap(arrow);
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(ListTile), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillColorAndStyle(WidgetTester tester) async {
  await _pick(tester, 1, ItemColor.values.first.label);
  await _pick(tester, 2, ItemStyle.values.first.label);
}

void main() {
  setUpMatchooseEnv();

  late Directory tmp;
  late String imagePath;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('save_item_test_');
    imagePath = '${tmp.path}/item_masked.png';
    File(imagePath).writeAsBytesSync(
      img.encodePng(img.Image(width: 80, height: 60, numChannels: 4)),
    );
  });

  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  Future<void> openScreen(WidgetTester tester) => pumpPushed(
        tester,
        SaveItemScreen(imagePath: imagePath, guideType: GuideType.tshirt),
      );

  testWidgets('เปิดหน้า => แสดงหัวข้อและช่องกรอก, ปุ่ม Add to Closet กดไม่ได้',
      (tester) async {
    await openScreen(tester);

    expect(find.text('Save Item'), findsOneWidget);
    expect(find.text('Select color'), findsOneWidget);
    expect(find.text('Select style'), findsOneWidget);
    expect(_addEnabled(tester), isFalse);
  });

  testWidgets('เลือก COLOR และ STYLE ครบ => ปุ่ม Add to Closet กดได้',
      (tester) async {
    await openScreen(tester);

    await _fillColorAndStyle(tester);

    expect(_addEnabled(tester), isTrue);
  });

  testWidgets('กดหัวใจ => ไอคอนสลับระหว่างหัวใจโปร่ง/เต็ม', (tester) async {
    await openScreen(tester);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('กด Add โดยไม่ใส่ชื่อ => SnackBar "Please enter a name" '
      'และไม่บันทึก', (tester) async {
    await openScreen(tester);
    await _fillColorAndStyle(tester);

    await tester.tap(_addButton);
    await tester.pump();

    expect(find.text('Please enter a name'), findsOneWidget);
    expect(_repo.items.value, isEmpty);
    expect(find.byType(SaveItemScreen), findsOneWidget);
  });

  testWidgets('ใส่ชื่อ + เลือกครบ แล้วกด Add => บันทึกเข้าตู้ '
      'และปิดหน้า', (tester) async {
    await openScreen(tester);
    await tester.enterText(find.byType(TextField), '  My Tee  ');
    await _fillColorAndStyle(tester);

    await tester.tap(_addButton);
    await waitUntil(
      tester,
      () => find.byType(SaveItemScreen).evaluate().isEmpty,
    );

    expect(_repo.items.value, hasLength(1));
    expect(_repo.items.value.single.name, 'My Tee');
    expect(File(imagePath).existsSync(), isFalse); // ไฟล์ temp ถูกย้ายไปแล้ว
    expect(launcherOpen, findsOneWidget);
  });

  testWidgets('กดถังขยะแล้ว Cancel => ยังอยู่หน้าเดิม ไฟล์ไม่หาย',
      (tester) async {
    await openScreen(tester);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Delete this item?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(SaveItemScreen), findsOneWidget);
    expect(File(imagePath).existsSync(), isTrue);
  });

  testWidgets('กดถังขยะแล้ว Delete => ลบไฟล์รูปและปิดหน้า', (tester) async {
    await openScreen(tester);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(File(imagePath).existsSync(), isFalse);
    expect(_repo.items.value, isEmpty);
  });
}