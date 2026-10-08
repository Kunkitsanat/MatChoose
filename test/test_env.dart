
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/outfit_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// path_provider จำลอง: ให้ Documents ชี้ไปโฟลเดอร์ temp
class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.docsDir);
  final String docsDir;

  @override
  Future<String?> getApplicationDocumentsPath() async => docsDir;
}

/// เรียกใน main() ของแต่ละไฟล์เทส
/// - ชี้ path_provider ไปโฟลเดอร์ temp
/// - โหลด repository ล่วงหน้า (เพื่อให้ load() ในหน้าจอจบทันที)
/// - เคลียร์ closet / outfits ก่อนทุกเทส (เทสใส่ข้อมูลเองผ่าน items.value)
void setUpMatchooseEnv() {
  late Directory docs;

  setUpAll(() async {
    docs = Directory.systemTemp.createTempSync('matchoose_test_');
    PathProviderPlatform.instance = _FakePathProvider(docs.path);
    await ClosetRepository.instance.load();
    await OutfitRepository.instance.load();
  });

  tearDownAll(() {
    if (docs.existsSync()) docs.deleteSync(recursive: true);
  });

  setUp(() {
    ClosetRepository.instance.items.value = const [];
    OutfitRepository.instance.outfits.value = const [];
  });
}

/// สร้างเสื้อผ้าจำลอง (รูปเป็น path ที่ไม่มีจริง — ไม่กระทบเทส)
ClothingItem testItem({
  required String id,
  String? name,
  ItemCategory category = ItemCategory.tops,
  ItemColor? color,
  ItemStyle? style,
  bool favorite = false,
}) =>
    ClothingItem(
      id: id,
      name: name ?? 'Item $id',
      imagePath: '/nonexistent/$id.png',
      category: category,
      color: color ?? ItemColor.values.first,
      style: style ?? ItemStyle.values.first,
      isFavorite: favorite,
      createdAt: DateTime(2024, 1, 1),
    );

MaterialApp _app(Widget home) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: home,
    );

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// แสดงหน้าเป็น root
Future<void> pumpRoot(WidgetTester tester, Widget screen) async {
  usePhoneScreen(tester);
  await tester.pumpWidget(_app(screen));
  await tester.pumpAndSettle();
}

/// แสดงหน้าโดยมี route ข้างล่าง (กด Back / pop ได้จริง)
/// launcher มีปุ่ม key 'launcher_open' ใช้เช็คว่ากลับมาหน้าแรกแล้ว
Future<void> pumpPushed(WidgetTester tester, Widget screen) async {
  usePhoneScreen(tester);
  await tester.pumpWidget(
    _app(
      Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: ElevatedButton(
              key: const Key('launcher_open'),
              onPressed: () => Navigator.of(ctx).push(
                MaterialPageRoute(builder: (_) => screen),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('launcher_open')));
  await tester.pumpAndSettle();
}

final Finder launcherOpen = find.byKey(const Key('launcher_open'));

/// รอ I/O จริง (เขียนไฟล์ JSON ฯลฯ) จนเงื่อนไขเป็นจริง
Future<void> waitUntil(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(end)) fail('Timeout รอเงื่อนไขไม่สำเร็จ');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

/// รอ I/O จริงช่วงสั้นๆ (ให้งานเขียนไฟล์เบื้องหลังจบ)
Future<void> settleReal(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pump();
}