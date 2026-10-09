// test/search_screen_test.dart
//
// ทดสอบหน้า SearchScreen + SearchResultScreen แบบง่ายๆ
// (ใช้ helpers/test_env.dart ร่วมกับเทสหน้าอื่น)
//   flutter test test/search_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/l10n/clothing_localizations.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';
import 'package:matchoose/screens/search/search_result_screen.dart';
import 'package:matchoose/screens/search/search_screen.dart';

import 'test_env.dart';

final _searchButton = find.byKey(const Key('search_button'));

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(SearchScreen)))!;

/// ตู้ตัวอย่าง: เสื้อธรรมดา 1 ตัว + กางเกง favorite 1 ตัว
void _seed() {
  ClosetRepository.instance.items.value = [
    testItem(id: '1', name: 'Blue Tee', category: ItemCategory.tops),
    testItem(
      id: '2',
      name: 'Red Jeans',
      category: ItemCategory.bottoms,
      favorite: true,
    ),
  ];
}

/// เปิดหน้า Search (ต้องมี Scaffold เพราะ TextField/Checkbox ต้องการ Material)
Future<void> _openSearch(
  WidgetTester tester, [
  Locale locale = const Locale('en'),
]) =>
    pumpRoot(tester, const Scaffold(body: SearchScreen()), locale: locale);

/// ภาษาที่ต้องการทดสอบ (เพิ่มภาษาใหม่ได้ที่นี่ที่เดียว)
const _locales = [Locale('en'), Locale('th')];

/// หาข้อความสรุปจำนวนผลลัพธ์ เช่น "2 items found" / "2 รายการ..."
/// เทียบแบบ "ไม่สนช่องว่าง" เพราะการเว้นวรรคระหว่างจำนวน/หน่วย/คำว่า found
/// ขึ้นกับไฟล์แปลของแต่ละภาษา ("1 itemfound" vs "1 item found")
Finder _countText(AppLocalizations l10n, int count) {
  String squash(String t) => t.replaceAll(RegExp(r'\s+'), '');
  final expected = squash(
    '$count ${count == 1 ? l10n.item : l10n.items}${l10n.found}',
  );
  return find.byWidgetPredicate(
    (w) => w is Text && squash(w.data ?? '') == expected,
    description: 'Text สรุปจำนวนผลลัพธ์ = $count',
  );
}

Future<void> _tapSearch(WidgetTester tester) async {
  await tester.ensureVisible(_searchButton);
  await tester.pumpAndSettle();
  await tester.tap(_searchButton);
  await tester.pumpAndSettle();
}

void main() {
  setUpMatchooseEnv();

  testWidgets('เปิดหน้า => แสดงหัวข้อ ช่องค้นหา ตัวกรอง และปุ่มค้นหา',
      (tester) async {
    await _openSearch(tester);
    final l10n = _l10n(tester);

    expect(find.text(l10n.search), findsOneWidget);
    expect(find.text(l10n.searchByName), findsOneWidget);
    expect(find.text(l10n.allCategories), findsOneWidget);
    expect(find.text(l10n.anyColor), findsOneWidget);
    expect(find.text(l10n.allStyles), findsOneWidget);
    expect(find.text(l10n.favoritesOnly), findsOneWidget);
    expect(_searchButton, findsOneWidget);
  });

  for (final locale in _locales) {
    testWidgets('[${locale.languageCode}] กดค้นหาโดยไม่ใส่ตัวกรอง => ไปหน้าผลลัพธ์ '
        'แสดงของทั้งหมด', (tester) async {
      _seed();
      await _openSearch(tester, locale);
      final l10n = _l10n(tester); // l10n ของภาษาที่กำลังทดสอบ

      await _tapSearch(tester);

      expect(find.byType(SearchResultScreen), findsOneWidget);
      expect(_countText(l10n, 2), findsOneWidget);
      expect(find.text('Blue Tee'), findsOneWidget);
      expect(find.text('Red Jeans'), findsOneWidget);
    });

    testWidgets('[${locale.languageCode}] ค้นหาด้วยชื่อ (ไม่สนตัวพิมพ์เล็ก/ใหญ่) '
        '=> เหลือเฉพาะที่ชื่อตรง', (tester) async {
      _seed();
      await _openSearch(tester, locale);
      final l10n = _l10n(tester);

      await tester.enterText(find.byType(TextField), 'blue');
      await _tapSearch(tester);

      expect(_countText(l10n, 1), findsOneWidget);
      expect(find.text('Blue Tee'), findsOneWidget);
      expect(find.text('Red Jeans'), findsNothing);
    });
  }

  testWidgets('เลือก Category จาก dropdown => แสดงเฉพาะหมวดนั้น',
      (tester) async {
    _seed();
    await _openSearch(tester);
    final l10n = _l10n(tester);

    await tester.tap(find.text(l10n.allCategories));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ItemCategory.bottoms.localizedLabel(l10n)).last);
    await tester.pumpAndSettle();

    await _tapSearch(tester);

    expect(find.text('Red Jeans'), findsOneWidget);
    expect(find.text('Blue Tee'), findsNothing);
  });

  testWidgets('ติ๊ก Favorites only => แสดงเฉพาะชิ้นที่ favorite',
      (tester) async {
    _seed();
    await _openSearch(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await _tapSearch(tester);

    expect(find.text('Red Jeans'), findsOneWidget);
    expect(find.text('Blue Tee'), findsNothing);
  });

  testWidgets('ค้นหาแล้วไม่เจอ => แสดงข้อความ "ไม่พบเสื้อผ้า"', (tester) async {
    _seed();
    await _openSearch(tester);
    final l10n = _l10n(tester);

    await tester.enterText(find.byType(TextField), 'zzz');
    await _tapSearch(tester);

    expect(find.text(l10n.noClothesFound), findsOneWidget);
    expect(find.text(l10n.noClothesFoundHint), findsOneWidget);
  });

  testWidgets('กดการ์ดในผลลัพธ์ => ไปหน้า PreviewItemScreen ของชิ้นนั้น',
      (tester) async {
    _seed();
    await _openSearch(tester);
    await _tapSearch(tester);

    await tester.tap(find.byKey(const Key('search_item_1')));
    await tester.pumpAndSettle();

    final preview =
        tester.widget<PreviewItemScreen>(find.byType(PreviewItemScreen));
    expect(preview.item.id, '1');
  });

  testWidgets('กดปุ่ม Back ในหน้าผลลัพธ์ => กลับหน้าค้นหา', (tester) async {
    _seed();
    await _openSearch(tester);
    await _tapSearch(tester);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(find.byType(SearchResultScreen), findsNothing);
    expect(find.byType(SearchScreen), findsOneWidget);
  });
}