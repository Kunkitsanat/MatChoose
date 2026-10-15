import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/models/outfit.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/outfit_repository.dart';
import 'package:matchoose/screens/outfit/outfit_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final outfitRepo = OutfitRepository.instance;
  final closet = ClosetRepository.instance;

  setUpAll(() async {
    // path_provider ใช้ platform channel ซึ่งไม่มีใน widget test
    // จึง mock ให้ชี้ไปที่โฟลเดอร์ temp
    final tempDir = Directory.systemTemp.createTempSync('outfit_test_').path;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tempDir,
    );

    // โหลดไว้ก่อนเลย initState ของหน้าจอจะได้ไม่ต้องรอ IO
    await outfitRepo.load();
    await closet.load();
  });

  setUp(() {
    outfitRepo.outfits.value = const [];
    closet.items.value = const [];
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: OutfitScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  ClothingItem item(String id, ItemCategory category) => ClothingItem(
        id: id,
        name: 'Item $id',
        imagePath: '/not/exist/$id.png', // ไม่มีไฟล์จริง จะแสดง broken icon
        category: category,
        color: ItemColor.black,
        style: ItemStyle.casual,
        isFavorite: false,
        createdAt: DateTime(2026, 1, 1),
      );

  Outfit outfit(String id, String name, List<String> itemIds) => Outfit(
        id: id,
        name: name,
        itemIds: itemIds,
        createdAt: DateTime(2026, 1, 1),
      );

  testWidgets('shows empty state when there are no saved outfits',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('My Outfits'), findsOneWidget);
    expect(find.text('No saved outfits yet'), findsOneWidget);
  });

  testWidgets('shows saved outfit with its name', (tester) async {
    closet.items.value = [
      item('1', ItemCategory.tops),
      item('2', ItemCategory.bottoms),
    ];
    outfitRepo.outfits.value = [
      outfit('o1', 'Weekend Look', ['1', '2']),
    ];

    await pumpScreen(tester);

    expect(find.text('Weekend Look'), findsOneWidget);
    expect(find.text('No saved outfits yet'), findsNothing);
  });

  testWidgets('deletes an outfit after confirming', (tester) async {
    closet.items.value = [item('1', ItemCategory.tops)];
    outfitRepo.outfits.value = [
      outfit('o1', 'Weekend Look', ['1']),
    ];

    await pumpScreen(tester);

    // เปิดเมนู ⋮ -> Delete
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // กดยืนยันใน dialog
    expect(find.text('Delete this outfit?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Weekend Look'), findsNothing);
    expect(find.text('No saved outfits yet'), findsOneWidget);
  });
}