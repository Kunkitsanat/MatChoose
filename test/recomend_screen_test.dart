
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';
import 'package:matchoose/screens/home/recommend_screen.dart';
import 'package:matchoose/services/recommendation_service.dart';

import 'test_env.dart';

/// หาเสื้อ+กางเกง style เดียวกันที่ RecommendationService ยอมจับคู่ให้
/// (วนหาคู่สีที่ใช้ได้ จะได้ไม่ต้องรู้กฎสีข้างใน service)
List<ClothingItem> _matchingItems() {
  const service = RecommendationService();
  for (final topColor in ItemColor.values) {
    for (final bottomColor in ItemColor.values) {
      final items = [
        testItem(
          id: 'top',
          name: 'Top',
          category: ItemCategory.tops,
          color: topColor,
        ),
        testItem(
          id: 'bottom',
          name: 'Bottom',
          category: ItemCategory.bottoms,
          color: bottomColor,
        ),
      ];
      if (service.recommendOutfits(items, random: Random(1)).isNotEmpty) {
        return items;
      }
    }
  }
  throw StateError('ไม่พบคู่สีที่ RecommendationService จับคู่ได้');
}

void main() {
  setUpMatchooseEnv();

  testWidgets('ตู้ว่าง => แสดง empty state "ยังจับคู่ชุดไม่ได้" ไม่มี PageView',
      (tester) async {
    await pumpPushed(tester, const RecommendScreen());

    expect(find.text('Recommend'), findsOneWidget);
    expect(find.text('ยังจับคู่ชุดไม่ได้'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('มีเสื้อ+กางเกงที่เข้ากัน => แสดงการ์ดชุด พร้อมป้าย style',
      (tester) async {
    ClosetRepository.instance.items.value = _matchingItems();
    await pumpPushed(tester, const RecommendScreen());

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('ยังจับคู่ชุดไม่ได้'), findsNothing);
    expect(find.text(ItemStyle.values.first.label), findsOneWidget);
    expect(find.byType(Image), findsAtLeastNWidgets(2)); // เสื้อ + กางเกง
  });

  testWidgets('กดรูปชิ้นในชุด => ไปหน้า PreviewItemScreen', (tester) async {
    ClosetRepository.instance.items.value = _matchingItems();
    await pumpPushed(tester, const RecommendScreen());

    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();

    expect(find.byType(PreviewItemScreen), findsOneWidget);
  });

  testWidgets('กดปุ่ม Shuffle => ยังแสดงชุดอยู่ ไม่ error', (tester) async {
    ClosetRepository.instance.items.value = _matchingItems();
    await pumpPushed(tester, const RecommendScreen());

    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pumpAndSettle();

    expect(find.byType(RecommendScreen), findsOneWidget);
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