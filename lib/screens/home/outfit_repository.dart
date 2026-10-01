import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/models/outfit.dart';
import 'package:matchoose/screens/add/closet_repository.dart';

/// เก็บชุดที่บันทึกไว้ในเครื่อง
///
/// หน้าอื่นฟังการเปลี่ยนแปลงผ่าน [outfits] (ValueListenable)
/// วางที่ lib/screens/home/outfit_repository.dart
class OutfitRepository {
  OutfitRepository._();

  static final OutfitRepository instance = OutfitRepository._();

  /// รายการชุดทั้งหมด (ใหม่สุดอยู่ก่อน)
  final ValueNotifier<List<Outfit>> outfits = ValueNotifier(const []);

  bool _loaded = false;
  File? _file;

  Future<File> _dbFile() async {
    final cached = _file;
    if (cached != null) return cached;

    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/outfits');
    if (!await dir.exists()) await dir.create(recursive: true);
    return _file = File('${dir.path}/outfits.json');
  }

  /// โหลดข้อมูลจากเครื่อง (เรียกซ้ำได้ ทำงานจริงแค่ครั้งแรก)
  Future<void> load() async {
    if (_loaded) return;

    try {
      final db = await _dbFile();

      if (await db.exists()) {
        final list = jsonDecode(await db.readAsString()) as List;
        final loaded = <Outfit>[];

        for (final e in list) {
          final m = e as Map<String, dynamic>;
          loaded.add(
            Outfit(
              id: m['id'] as String,
              name: m['name'] as String? ?? 'Outfit',
              itemIds: (m['itemIds'] as List? ?? const [])
                  .map((x) => x as String)
                  .toList(),
              createdAt: DateTime.tryParse(m['createdAt'] as String? ?? '') ??
                  DateTime.now(),
            ),
          );
        }
        outfits.value = loaded;
      }
    } catch (e) {
      debugPrint('Outfit load error: $e');
    }

    _loaded = true;
  }

  /// บันทึกชุดใหม่ คืน null ถ้ามีชุดเดียวกัน (เสื้อผ้าชุดเดียวกันทุกชิ้น) อยู่แล้ว
  Future<Outfit?> add({
    required List<String> itemIds,
    String? name,
  }) async {
    await load();

    if (_isDuplicate(itemIds)) return null;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final outfit = Outfit(
      id: id,
      name: name ?? 'Outfit ${outfits.value.length + 1}',
      itemIds: List.unmodifiable(itemIds),
      createdAt: DateTime.now(),
    );

    outfits.value = [outfit, ...outfits.value];
    await _persist();
    return outfit;
  }

  Future<void> rename(String id, String name) async {
    outfits.value = [
      for (final o in outfits.value)
        o.id == id ? o.copyWith(name: name) : o,
    ];
    await _persist();
  }

  Future<void> delete(String id) async {
    outfits.value = outfits.value.where((o) => o.id != id).toList();
    await _persist();
  }

  /// แปลง id ในชุดเป็น ClothingItem จริงจาก closet
  /// (ข้ามชิ้นที่ถูกลบออกจากตู้ไปแล้ว)
  List<ClothingItem> itemsOf(Outfit outfit) {
    final all = ClosetRepository.instance.items.value;
    return [
      for (final id in outfit.itemIds)
        ...all.where((i) => i.id == id),
    ];
  }

  bool _isDuplicate(List<String> itemIds) {
    final key = ([...itemIds]..sort()).join(',');
    return outfits.value.any(
      (o) => ([...o.itemIds]..sort()).join(',') == key,
    );
  }

  Future<void> _persist() async {
    final data = outfits.value
        .map((o) => {
              'id': o.id,
              'name': o.name,
              'itemIds': o.itemIds,
              'createdAt': o.createdAt.toIso8601String(),
            })
        .toList();

    await (await _dbFile()).writeAsString(jsonEncode(data));
  }
}