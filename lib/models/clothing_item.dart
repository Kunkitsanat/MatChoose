enum ClothingCategory {
  shirt,
  tshirt,
  pants,
  shorts,
}

enum ClothingColor {
  black,
  white,
  gray,
  silver,

  red,
  burgundy,
  pink,
  coral,
  orange,
  peach,
  yellow,
  gold,

  green,
  olive,
  mint,
  teal,

  blue,
  skyBlue,
  navy,
  royalBlue,

  purple,
  lavender,

  brown,
  tan,
  beige,
  cream,
  khaki,

  other,
}

enum ClothingFormality {
  casual,
  formal,
}

class ClothingItem {
  final String id;
  final String name;
  final String imagePath;
  final ClothingCategory category;
  final List<ClothingColor> colors;
  final ClothingFormality formality;
  final bool isFavorite;

  ClothingItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.colors,
    required this.formality,
    this.isFavorite = false,
  });
}