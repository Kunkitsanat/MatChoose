import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:matchoose/models/clothing_item.dart';

/// เก็บเสื้อผ้าที่บันทึกไว้ในเครื่อง
///
/// หน้าอื่นฟังการเปลี่ยนแปลงผ่าน [items] (ValueListenable)
class ClosetRepository {
  ClosetRepository._();

  static final ClosetRepository instance = ClosetRepository._();

  /// รายการเสื้อผ้าทั้งหมด (ใหม่สุดอยู่ก่อน)
  final ValueNotifier<List<ClothingItem>> items = ValueNotifier(const []);

  bool _loaded = false;
  Directory? _dir;

  Future<Directory> _closetDir() async {
    final cached = _dir;
    if (cached != null) return cached;

    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/closet');
    if (!await dir.exists()) await dir.create(recursive: true);
    return _dir = dir;
  }

  Future<File> _dbFile() async =>
      File('${(await _closetDir()).path}/closet.json');

  /// โหลดข้อมูลจากเครื่อง (เรียกซ้ำได้ ทำงานจริงแค่ครั้งแรก)
  Future<void> load() async {
    if (_loaded) return;

    try {
      final dir = await _closetDir();
      final db = await _dbFile();

      if (await db.exists()) {
        final list = jsonDecode(await db.readAsString()) as List;
        final loaded = <ClothingItem>[];

        for (final e in list) {
          final m = e as Map<String, dynamic>;
          final path = '${dir.path}/${m['file']}';
          if (!File(path).existsSync()) continue; // ไฟล์รูปหาย ข้ามไป

          loaded.add(
            ClothingItem(
              id: m['id'] as String,
              name: m['name'] as String? ?? 'Unnamed Item',
              imagePath: path,
              category: _enumByName(
                  ItemCategory.values, m['category'], ItemCategory.tops),
              color: _enumByName(ItemColor.values, m['color'], ItemColor.other),
              style:
                  _enumByName(ItemStyle.values, m['style'], ItemStyle.casual),
              isFavorite: m['favorite'] as bool? ?? false,
              createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
                  DateTime.now(),
            ),
          );
        }
        items.value = loaded;
      }
    } catch (e) {
      debugPrint('Closet load error: $e');
    }

    _loaded = true;
  }

  /// บันทึกเสื้อผ้าชิ้นใหม่: copy รูปจาก temp -> closet แล้วเขียน JSON
  Future<ClothingItem> add({
    required String tempImagePath,
    required String name,
    required ItemCategory category,
    required ItemColor color,
    required ItemStyle style,
    bool isFavorite = false,
  }) async {
    await load();

    final dir = await _closetDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final dest = '${dir.path}/$id.png';

    await File(tempImagePath).copy(dest);

    final item = ClothingItem(
      id: id,
      name: name,
      imagePath: dest,
      category: category,
      color: color,
      style: style,
      isFavorite: isFavorite,
      createdAt: DateTime.now(),
    );

    items.value = [item, ...items.value];
    await _persist();

    // ลบไฟล์ temp ทิ้ง (ไม่ critical ถ้าลบไม่สำเร็จ)
    try {
      await File(tempImagePath).delete();
    } catch (_) {}

    return item;
  }

  Future<void> _persist() async {
    final data = items.value
        .map((i) => {
              'id': i.id,
              'name': i.name,
              'file': i.imagePath.substring(i.imagePath.lastIndexOf('/') + 1),
              'category': i.category.name,
              'color': i.color.name,
              'style': i.style.name,
              'favorite': i.isFavorite,
              'createdAt': i.createdAt.toIso8601String(),
            })
        .toList();

    await (await _dbFile()).writeAsString(jsonEncode(data));
  }

  Future<void> toggleFavorite(String id) async {
  items.value = [
    for (final i in items.value)
      i.id == id
          ? ClothingItem(
              id: i.id,
              name: i.name,
              imagePath: i.imagePath,
              category: i.category,
              color: i.color,
              style: i.style,
              createdAt: i.createdAt,
              isFavorite: !i.isFavorite,
            )
          : i,
  ];
  await _persist();
  }

  Future<void> delete(String id) async {
    final target = items.value.where((i) => i.id == id).toList();
    items.value = items.value.where((i) => i.id != id).toList();
    await _persist();

    // ลบไฟล์รูปด้วย (ไม่ critical ถ้าลบไม่สำเร็จ)
    for (final t in target) {
      try {
        await File(t.imagePath).delete();
      } catch (_) {}
    }
  }
}

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}