import 'dart:ui' show Color;

// ============================================================
// Enums (ย้ายมาจาก save_item_screen.dart เพื่อให้หลายหน้าใช้ร่วมกันได้)
// ============================================================

/// หมวดหมู่ของเสื้อผ้า ลำดับในนี้คือลำดับที่แสดงบนหน้า home
enum ItemCategory {
  tops('Tops & Jackets'),
  bottoms('Bottoms'),
  shoes('Shoes');

  const ItemCategory(this.label);
  final String label;
}

enum ItemStyle {
  casual('Casual Wear'),
  formal('Formal Wear');

  const ItemStyle(this.label);
  final String label;
}

/// สีให้เลือก (`other` ไม่มีสีตายตัว จะแสดงเป็นวงกลมรุ้งแทน)
enum ItemColor {
  black('Black', Color(0xFF1A1A1A)),
  white('White', Color(0xFFFFFFFF)),
  gray('Gray', Color(0xFF9E9E9E)),
  silver('Silver', Color(0xFFC0C0C0)),
  red('Red', Color(0xFFD32F2F)),
  burgundy('Burgundy', Color(0xFF800020)),
  pink('Pink', Color(0xFFF48FB1)),
  coral('Coral', Color(0xFFFF7F50)),
  orange('Orange', Color(0xFFFB8C00)),
  peach('Peach', Color(0xFFFFCBA4)),
  yellow('Yellow', Color(0xFFFDD835)),
  gold('Gold', Color(0xFFD4AF37)),
  green('Green', Color(0xFF43A047)),
  olive('Olive', Color(0xFF808000)),
  mint('Mint', Color(0xFF98E8C1)),
  teal('Teal', Color(0xFF008080)),
  blue('Blue', Color(0xFF1E88E5)),
  skyBlue('Sky Blue', Color(0xFF87CEEB)),
  navy('Navy', Color(0xFF1F2A5C)),
  royalBlue('Royal Blue', Color(0xFF2F52E0)),
  purple('Purple', Color(0xFF7B1FA2)),
  lavender('Lavender', Color(0xFFB9A7E0)),
  brown('Brown', Color(0xFF6D4C41)),
  tan('Tan', Color(0xFFD2B48C)),
  beige('Beige', Color(0xFFE8DCC4)),
  cream('Cream', Color(0xFFFFF3D6)),
  khaki('Khaki', Color(0xFFC3B091)),
  other('Other', null);

  const ItemColor(this.label, this.swatch);
  final String label;
  final Color? swatch;
}

// ============================================================
// Color grouping (ใช้กับ RecommendationService)
// ============================================================

/// กลุ่มสี: neutral = เข้ากับทุกอย่าง, earth = โทนดิน,
/// warm = โทนอุ่น, cool = โทนเย็น
enum ColorGroup { neutral, earth, warm, cool, other }

extension ItemColorX on ItemColor {
  ColorGroup get group {
    switch (this) {
      case ItemColor.black:
      case ItemColor.white:
      case ItemColor.gray:
      case ItemColor.silver:
      case ItemColor.navy:
        return ColorGroup.neutral;

      case ItemColor.brown:
      case ItemColor.tan:
      case ItemColor.beige:
      case ItemColor.cream:
      case ItemColor.khaki:
      case ItemColor.olive:
        return ColorGroup.earth;

      case ItemColor.red:
      case ItemColor.burgundy:
      case ItemColor.pink:
      case ItemColor.coral:
      case ItemColor.orange:
      case ItemColor.peach:
      case ItemColor.yellow:
      case ItemColor.gold:
        return ColorGroup.warm;

      case ItemColor.green:
      case ItemColor.mint:
      case ItemColor.teal:
      case ItemColor.blue:
      case ItemColor.skyBlue:
      case ItemColor.royalBlue:
      case ItemColor.purple:
      case ItemColor.lavender:
        return ColorGroup.cool;

      case ItemColor.other:
        return ColorGroup.other;
    }
  }

  /// สีจัดจ้าน (ไม่ควรใส่คู่กับสีจัดอีกสี)
  bool get isBold => const {
        ItemColor.red,
        ItemColor.orange,
        ItemColor.yellow,
        ItemColor.royalBlue,
        ItemColor.purple,
        ItemColor.green,
        ItemColor.coral,
      }.contains(this);
}

// ============================================================
// Model
// ============================================================

/// เสื้อผ้า 1 ชิ้นในตู้
class ClothingItem {
  const ClothingItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.color,
    required this.style,
    required this.createdAt,
    this.isFavorite = false,
  });

  final String id;
  final String name;

  /// path เต็มของรูป PNG โปร่งใสในโฟลเดอร์ documents ของแอป
  final String imagePath;

  final ItemCategory category;
  final ItemColor color;
  final ItemStyle style;
  final bool isFavorite;
  final DateTime createdAt;

  /// สร้างสำเนาพร้อมเปลี่ยนบาง field (เพิ่ม field ใหม่ในอนาคตแก้ที่นี่ที่เดียว)
  ClothingItem copyWith({
    String? name,
    ItemCategory? category,
    ItemColor? color,
    ItemStyle? style,
    bool? isFavorite,
  }) {
    return ClothingItem(
      id: id,
      name: name ?? this.name,
      imagePath: imagePath,
      category: category ?? this.category,
      color: color ?? this.color,
      style: style ?? this.style,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}