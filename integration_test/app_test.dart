// integration_test/app_test.dart
//
// Integration test แบบง่ายๆ: รันบนเครื่อง/emulator จริง (ใช้ path_provider และ
// ไฟล์จริง ไม่มีการจำลองอะไร)
//
// Flow ที่ทดสอบ:
//   1. กดแท็บล่างครบทั้ง 5 แท็บ
//   2. เพิ่มเสื้อ+กางเกง -> Home แสดง -> Preview -> favorite -> Try Outfit
//      -> Save Outfit -> Recommend -> ลบของ
//
// ===== ก่อนรัน =====
// 1) pubspec.yaml:
//      dev_dependencies:
//        integration_test:
//          sdk: flutter
// 2) แก้ import ที่มี TODO ให้ตรงกับโปรเจกต์
// 3) ใช้ emulator / เครื่องเทสเท่านั้น: เทสเขียนข้อมูลลงตู้เสื้อผ้าจริงของแอป
//    (แต่จะลบของที่ตัวเองสร้างตอนจบ)
//
//   flutter test integration_test/app_test.dart -d <device-id>

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:integration_test/integration_test.dart';
import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/models/app_language.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/add_clothing_screen.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/home_screen.dart';
import 'package:matchoose/screens/home/outfit_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';
import 'package:matchoose/screens/home/recommend_screen.dart';
import 'package:matchoose/screens/home/try_outfit_screen.dart';
import 'package:matchoose/screens/main_screen.dart';
import 'package:matchoose/screens/outfit/outfit_screen.dart';
import 'package:matchoose/screens/search/search_screen.dart';
import 'package:matchoose/screens/setting/setting_screen.dart';

final _closet = ClosetRepository.instance;
final _outfits = OutfitRepository.instance;

Widget _app() => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: MainScreen(
        selectedLanguage: AppLanguage.values.first,
        onLanguageChanged: (_) {},
      ),
    );

/// กดไอคอนบน NavigationBar (กันชนกับไอคอนชื่อเดียวกันในหน้าอื่น)
Finder _navIcon(IconData icon) => find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(icon),
    );

/// pump ไปเรื่อยๆ จนเจอ finder (ใช้รอ I/O จริง)
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) fail('Timeout: ไม่พบ $finder');
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

/// เพิ่มเสื้อผ้าเข้าตู้จริง (สี neutral + style เดียวกัน => Recommend จับคู่ได้)
Future<ClothingItem> _addItem(
  String name,
  ItemCategory category,
  Directory tmp,
) {
  final file = File('${tmp.path}/$name.png')
    ..writeAsBytesSync(
      img.encodePng(img.Image(width: 80, height: 60, numChannels: 4)),
    );
  return _closet.add(
    tempImagePath: file.path,
    name: name,
    category: category,
    color: ItemColor.values.firstWhere((c) => c.group == ColorGroup.neutral),
    style: ItemStyle.values.first,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Matchoose app', () {
    testWidgets('กดแท็บล่างครบ 5 แท็บ => แสดงหน้าที่ถูกต้อง', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(_navIcon(Icons.bookmark_border));
      await tester.pumpAndSettle();
      expect(find.byType(OutfitScreen), findsOneWidget);
      expect(find.text('My Outfits'), findsOneWidget);

      await tester.tap(_navIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.byType(AddClothingScreen), findsOneWidget);

      await tester.tap(_navIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);

      await tester.tap(_navIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      await tester.tap(_navIcon(Icons.inventory_2_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('flow ตู้เสื้อผ้า: Home -> Preview -> favorite -> Try Outfit '
        '-> Save -> Recommend -> ลบของ', (tester) async {
      final tmp = Directory.systemTemp.createTempSync('it_test_');
      final top = await _addItem('IT Top', ItemCategory.tops, tmp);
      final bottom = await _addItem('IT Bottom', ItemCategory.bottoms, tmp);

      try {
        await tester.pumpWidget(_app());
        await _pumpUntil(tester, find.text('IT Top'));
        final l10n = AppLocalizations.of(
          tester.element(find.byType(HomeScreen)),
        )!;

        // 1) Home แสดงของที่เพิ่ม
        expect(find.text('IT Top'), findsOneWidget);
        expect(find.text('IT Bottom'), findsOneWidget);

        // 2) กดการ์ด -> Preview -> กดหัวใจ -> favorite ถูกบันทึก
        await tester.tap(find.text('IT Top'));
        await tester.pumpAndSettle();
        expect(find.byType(PreviewItemScreen), findsOneWidget);

        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();
        expect(
          _closet.items.value.firstWhere((i) => i.id == top.id).isFavorite,
          isTrue,
        );

        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);

        // 3) Try Outfit -> Save Outfit
        await tester.tap(find.text(l10n.tryOutfit));
        await tester.pumpAndSettle();
        expect(find.byType(TryOutfitScreen), findsOneWidget);

        await tester.tap(find.text('Save Outfit'));
        await _pumpUntil(tester, find.text('Outfit saved'));
        expect(
          _outfits.outfits.value.any(
            (o) =>
                o.itemIds.contains(top.id) && o.itemIds.contains(bottom.id),
          ),
          isTrue,
        );

        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();

        // 4) Recommend แสดงชุดที่จับคู่ให้
        await tester.tap(find.text(l10n.recommend));
        await tester.pumpAndSettle();
        expect(find.byType(RecommendScreen), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);

        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pumpAndSettle();

        // 5) ลบของจากหน้า Preview -> หายจาก Home
        await tester.tap(find.text('IT Top'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await _pumpUntil(tester, find.byType(HomeScreen));

        expect(find.text('IT Top'), findsNothing);
        expect(_closet.items.value.any((i) => i.id == top.id), isFalse);
      } finally {
        // ล้างข้อมูลที่เทสสร้างไว้
        for (final o in _outfits.outfits.value
            .where((o) =>
                o.itemIds.contains(top.id) || o.itemIds.contains(bottom.id))
            .toList()) {
          await _outfits.delete(o.id);
        }
        await _closet.delete(top.id);
        await _closet.delete(bottom.id);
        if (tmp.existsSync()) tmp.deleteSync(recursive: true);
      }
    });
  });
}