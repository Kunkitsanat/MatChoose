// test/recommend_screen_test.dart
//
// ทดสอบหน้า RecommendScreen แบบง่ายๆ
// (กฎจับคู่: style ต้องเหมือนกัน + สีต้องเข้ากัน — ในเทสใช้สีกลุ่ม neutral
//  ซึ่งเข้ากับทุกอย่าง)
//   flutter test test/recommend_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';
import 'package:matchoose/screens/home/recommend_screen.dart';

import 'test_env.dart';

final _neutral =
    ItemColor.values.firstWhere((c) => c.group == ColorGroup.neutral);

ClothingItem _item(
  String id,
  ItemCategory category, {
  ItemStyle? style,
}) =>
    testItem(id: id, category: category, color: _neutral, style: style);

void main() {
  setUpMatchooseEnv();

  testWidgets('ตู้ว่าง => แสดง "ยังจับคู่ชุดไม่ได้" ไม่มี PageView',
      (tester) async {
    await pumpPushed(tester, const RecommendScreen());

    expect(find.text('Recommend'), findsOneWidget);
    expect(find.text('ยังจับคู่ชุดไม่ได้'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('มีเสื้อ + กางเกง style เดียวกัน => แสดงชุด 2 ชิ้น พร้อมป้าย style',
      (tester) async {
    ClosetRepository.instance.items.value = [
      _item('t', ItemCategory.tops),
      _item('b', ItemCategory.bottoms),
    ];
    await pumpPushed(tester, const RecommendScreen());

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text(ItemStyle.values.first.label), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
  });


  testWidgets('เสื้อกับกางเกงคนละ style => จับคู่ไม่ได้ แสดง empty state',
      (tester) async {
    ClosetRepository.instance.items.value = [
      _item('t', ItemCategory.tops, style: ItemStyle.values[0]),
      _item('b', ItemCategory.bottoms, style: ItemStyle.values[1]),
    ];
    await pumpPushed(tester, const RecommendScreen());

    expect(find.text('ยังจับคู่ชุดไม่ได้'), findsOneWidget);
  });

  testWidgets('กดรูปชิ้นในชุด => ไปหน้า PreviewItemScreen', (tester) async {
    ClosetRepository.instance.items.value = [
      _item('t', ItemCategory.tops),
      _item('b', ItemCategory.bottoms),
    ];
    await pumpPushed(tester, const RecommendScreen());

    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();

    expect(find.byType(PreviewItemScreen), findsOneWidget);
  });

  testWidgets('กดปุ่ม Shuffle => ยังแสดงชุดอยู่ ไม่ error', (tester) async {
    ClosetRepository.instance.items.value = [
      _item('t', ItemCategory.tops),
      _item('b', ItemCategory.bottoms),
    ];
    await pumpPushed(tester, const RecommendScreen());

    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('กดปุ่ม Back => ปิดหน้า กลับหน้าก่อนหน้า', (tester) async {
    await pumpPushed(tester, const RecommendScreen());

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.byType(RecommendScreen), findsNothing);
    expect(launcherOpen, findsOneWidget);
  });
}