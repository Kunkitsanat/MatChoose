import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/outfit_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';
import 'package:matchoose/screens/home/try_outfit_screen.dart';

import 'test_env.dart';

final _saveLabel = find.text('Save Outfit');

/// ปุ่ม Save Outfit กดได้หรือไม่
bool _saveEnabled(WidgetTester tester) => tester
    .widget<FilledButton>(
      find.ancestor(
        of: _saveLabel,
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ),
    )
    .onPressed != null;

void _seed({int tops = 1}) {
  ClosetRepository.instance.items.value = [
    for (var i = 1; i <= tops; i++)
      testItem(id: 't$i', category: ItemCategory.tops),
    testItem(id: 'b1', category: ItemCategory.bottoms),
  ];
}

void main() {
  setUpMatchooseEnv();

  testWidgets('ตู้ว่าง => แต่ละแถวบอกว่ายังไม่มีของ และ Save Outfit กดไม่ได้',
      (tester) async {
    await pumpPushed(tester, const TryOutfitScreen());

    expect(find.text('Try Outfit'), findsOneWidget);
    // textContaining: ไม่ผูกกับถ้อยคำเต็มของข้อความ "ยังไม่มี ..." / "No ..."
    expect(find.textContaining(ItemCategory.tops.label), findsOneWidget);
    expect(find.textContaining(ItemCategory.bottoms.label), findsOneWidget);
    expect(_saveEnabled(tester), isFalse);
  });

  testWidgets('มีเสื้อและกางเกง => แสดง 2 แถว และ Save Outfit กดได้',
      (tester) async {
    _seed();
    await pumpPushed(tester, const TryOutfitScreen());

    expect(find.byType(PageView), findsNWidgets(2));
    expect(_saveEnabled(tester), isTrue);
  });

  testWidgets('กด Save Outfit => บันทึกชุดและแสดง "Outfit saved"',
      (tester) async {
    _seed();
    await pumpPushed(tester, const TryOutfitScreen());

    await tester.tap(_saveLabel);
    await waitUntil(
      tester,
      () => find.text('Outfit saved').evaluate().isNotEmpty,
    );

    final saved = OutfitRepository.instance.outfits.value;
    expect(saved, hasLength(1));
    expect(saved.single.itemIds, ['t1', 'b1']);
  });

  testWidgets('เลื่อนแถวเสื้อไปชิ้นที่ 2 แล้วกด Save => ชุดใช้ชิ้นที่เลือก',
      (tester) async {
    _seed(tops: 2);
    await pumpPushed(tester, const TryOutfitScreen());

    await tester.drag(find.byType(PageView).first, const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(_saveLabel);
    await waitUntil(
      tester,
      () => find.text('Outfit saved').evaluate().isNotEmpty,
    );

    expect(
      OutfitRepository.instance.outfits.value.single.itemIds,
      ['t2', 'b1'],
    );
  });

  testWidgets('กดรูปเสื้อผ้า => ไปหน้า PreviewItemScreen', (tester) async {
    _seed();
    await pumpPushed(tester, const TryOutfitScreen());

    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();

    expect(find.byType(PreviewItemScreen), findsOneWidget);
  });

  testWidgets('กดปุ่ม Back => ปิดหน้า กลับหน้าก่อนหน้า', (tester) async {
    await pumpPushed(tester, const TryOutfitScreen());

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.byType(TryOutfitScreen), findsNothing);
    expect(launcherOpen, findsOneWidget);
  });
}