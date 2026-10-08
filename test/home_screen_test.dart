

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/home_screen.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';
import 'package:matchoose/screens/home/recommend_screen.dart';
import 'package:matchoose/screens/home/try_outfit_screen.dart';

import 'test_env.dart';

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(HomeScreen)))!;

void main() {
  setUpMatchooseEnv();

  testWidgets('ตู้ว่าง => แสดงข้อความ empty และไม่มีหมวดใดๆ', (tester) async {
    await pumpRoot(tester, const HomeScreen());
    final l10n = _l10n(tester);

    expect(find.text('Matchoose'), findsOneWidget);
    expect(find.text(l10n.emptyCloset), findsOneWidget);
    expect(find.text(l10n.emptyClosetHint), findsOneWidget);
    expect(find.text(l10n.seeAll), findsNothing);
  });

  testWidgets('มีเสื้อผ้า => แสดงหมวด (หัวข้อ + See all) และชื่อชิ้น '
      'เฉพาะหมวดที่มีของ', (tester) async {
    ClosetRepository.instance.items.value = [
      testItem(id: '1', name: 'Blue Tee', category: ItemCategory.tops),
      testItem(id: '2', name: 'Jeans', category: ItemCategory.bottoms),
    ];
    await pumpRoot(tester, const HomeScreen());
    final l10n = _l10n(tester);

    expect(find.text(ItemCategory.tops.label), findsOneWidget);
    expect(find.text(ItemCategory.bottoms.label), findsOneWidget);
    expect(find.text('Blue Tee'), findsOneWidget);
    expect(find.text('Jeans'), findsOneWidget);
    expect(find.text(l10n.seeAll), findsNWidgets(2));
    expect(find.text(l10n.emptyCloset), findsNothing);
  });

  testWidgets('ชิ้นที่ favorite มีหัวใจ ชิ้นที่ไม่ favorite ไม่มี',
      (tester) async {
    ClosetRepository.instance.items.value = [
      testItem(id: '1', name: 'Fav Tee', favorite: true),
      testItem(id: '2', name: 'Plain Tee'),
    ];
    await pumpRoot(tester, const HomeScreen());

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('เพิ่มของเข้า repository ขณะเปิดหน้า => รายการอัปเดตทันที',
      (tester) async {
    await pumpRoot(tester, const HomeScreen());
    expect(find.text('New Shirt'), findsNothing);

    ClosetRepository.instance.items.value = [
      testItem(id: '9', name: 'New Shirt'),
    ];
    await tester.pumpAndSettle();

    expect(find.text('New Shirt'), findsOneWidget);
  });

  testWidgets('กดปุ่ม Recommend => ไปหน้า RecommendScreen', (tester) async {
    await pumpRoot(tester, const HomeScreen());

    await tester.tap(find.text(_l10n(tester).recommend));
    await tester.pumpAndSettle();

    expect(find.byType(RecommendScreen), findsOneWidget);
  });

  testWidgets('กดปุ่ม Try Outfit => ไปหน้า TryOutfitScreen', (tester) async {
    await pumpRoot(tester, const HomeScreen());

    await tester.tap(find.text(_l10n(tester).tryOutfit));
    await tester.pumpAndSettle();

    expect(find.byType(TryOutfitScreen), findsOneWidget);
  });

  testWidgets('กดเสื้อผ้า => ไปหน้า PreviewItemScreen ของชิ้นนั้น',
      (tester) async {
    final item = testItem(id: '1', name: 'Blue Tee');
    ClosetRepository.instance.items.value = [item];
    await pumpRoot(tester, const HomeScreen());

    await tester.tap(find.text('Blue Tee'));
    await tester.pumpAndSettle();

    final preview = tester.widget<PreviewItemScreen>(find.byType(PreviewItemScreen));
    expect(preview.item.id, item.id);
  });
}