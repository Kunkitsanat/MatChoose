/// ชุดที่บันทึกไว้ 1 ชุด (เก็บแค่ id ของเสื้อผ้า ไม่ copy รูปซ้ำ)
/// วางที่ lib/models/outfit.dart
class Outfit {
  const Outfit({
    required this.id,
    required this.name,
    required this.itemIds,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// id ของ ClothingItem ที่อยู่ในชุดนี้ (เรียงตาม tops -> bottoms -> ...)
  final List<String> itemIds;
  final DateTime createdAt;

  Outfit copyWith({String? name}) {
    return Outfit(
      id: id,
      name: name ?? this.name,
      itemIds: itemIds,
      createdAt: createdAt,
    );
  }
}