

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';

import 'test_env.dart';

final _repo = ClosetRepository.instance;

void main() {
  setUpMatchooseEnv();

  late ClothingItem item;

  setUp(() {
    item = testItem(id: '1', name: 'Blue Tee');
    _repo.items.value = [item];
  });

  testWidgets('แสดงหัวข้อ, Category, Color และ Style ของชิ้นนั้น',
      (tester) async {
    await pumpPushed(tester, PreviewItemScreen(item: item));

    expect(find.text('Preview Item'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text(item.category.label), findsOneWidget);
    expect(find.text('Color'), findsOneWidget);
    expect(find.text(item.color.label), findsOneWidget);
    expect(find.text(item.style.label), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('กดหัวใจ => favorite ใน repository เป็น true และไอคอนเปลี่ยน, '
      'กดอีกครั้ง => กลับเป็น false', (tester) async {
    await pumpPushed(tester, PreviewItemScreen(item: item));

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();
    await settleReal(tester);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(_repo.items.value.single.isFavorite, isTrue);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    await settleReal(tester);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(_repo.items.value.single.isFavorite, isFalse);
  });

  testWidgets('กดปุ่ม Back => ปิดหน้า กลับหน้าก่อนหน้า', (tester) async {
    await pumpPushed(tester, PreviewItemScreen(item: item));

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.byType(PreviewItemScreen), findsNothing);
    expect(launcherOpen, findsOneWidget);
  });

  testWidgets('กดถังขยะ => dialog ยืนยัน; กด Cancel => ยังอยู่หน้าเดิม '
      'ของไม่หาย', (tester) async {
    await pumpPushed(tester, PreviewItemScreen(item: item));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('Delete this item?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this item?'), findsNothing);
    expect(find.byType(PreviewItemScreen), findsOneWidget);
    expect(_repo.items.value, hasLength(1));
  });

  testWidgets('กดถังขยะแล้วกด Delete => ลบออกจากตู้ และปิดหน้า',
      (tester) async {
    await pumpPushed(tester, PreviewItemScreen(item: item));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await waitUntil(
      tester,
      () => find.byType(PreviewItemScreen).evaluate().isEmpty,
    );

    expect(_repo.items.value, isEmpty);
    expect(launcherOpen, findsOneWidget);
  });
}