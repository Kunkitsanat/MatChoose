import 'dart:math';

import 'package:matchoose/models/clothing_item.dart';

/// ชุด 1 ชุดที่จับคู่แล้ว: เสื้อ + กางเกง (+ รองเท้าถ้ามีที่เข้ากัน)
class Outfit {
  const Outfit({
    required this.top,
    required this.bottom,
    required this.score,
    this.shoes,
  });

  final ClothingItem top;
  final ClothingItem bottom;
  final ClothingItem? shoes;

  /// ยิ่งมากยิ่งเข้ากัน (ใช้เรียงลำดับ)
  final int score;

  List<ClothingItem> get items => [top, bottom, if (shoes != null) shoes!];

  /// ทุกชิ้นในชุดมี style เดียวกันเสมอ (score() ตัดคู่ที่ style ไม่ตรงทิ้ง)
  ItemStyle get style => top.style;
}

/// แนะนำเสื้อผ้าที่เข้ากัน โดยดูจาก style และสี
class RecommendationService {
  const RecommendationService();

  /// แต่ละชิ้นปรากฏในชุดที่แนะนำได้กี่ครั้ง (กันเสื้อตัวเดียวซ้ำทั้งลิสต์)
  static const int _maxReuse = 2;

  // ------------------------------------------------------------
  // Outfit (ใช้กับปุ่ม Recommend บนหน้า Home)
  // ------------------------------------------------------------

  /// สร้างชุดที่เข้ากันจากตู้เสื้อผ้า เรียงคะแนนมาก -> น้อย
  ///
  /// - ต้องมีทั้งเสื้อและกางเกงถึงจะเกิดชุด
  /// - รองเท้าเป็น optional: เลือกคู่ที่เข้ากับทั้งเสื้อและกางเกงที่สุด
  ///   ถ้าไม่มีรองเท้าที่เข้ากันเลย ชุดนั้นจะไม่มีรองเท้า
  /// - ชุดที่คะแนนเท่ากันสลับลำดับตาม [random] (ส่ง seed ต่างกัน = shuffle)
  List<Outfit> recommendOutfits(
    List<ClothingItem> closet, {
    int limit = 10,
    Random? random,
  }) {
    final rnd = random ?? Random();

    final tops = closet.where((i) => i.category == ItemCategory.tops);
    final bottoms = closet.where((i) => i.category == ItemCategory.bottoms);
    final shoes = closet.where((i) => i.category == ItemCategory.shoes);

    final entries = <({Outfit outfit, double tie})>[];

    for (final t in tops) {
      for (final b in bottoms) {
        final tb = score(t, b);
        if (tb == 0) continue;

        // หารองเท้าที่เข้ากับทั้งเสื้อและกางเกง
        ClothingItem? bestShoe;
        var bestShoeScore = 0;
        var bestTie = -1.0;
        for (final s in shoes) {
          final ts = score(t, s);
          final bs = score(b, s);
          if (ts == 0 || bs == 0) continue;

          final total = ts + bs;
          final tie = rnd.nextDouble();
          if (total > bestShoeScore ||
              (total == bestShoeScore && tie > bestTie)) {
            bestShoe = s;
            bestShoeScore = total;
            bestTie = tie;
          }
        }

        // score() ให้โบนัส favorite เฉพาะชิ้นที่สอง จึงบวกของเสื้อเพิ่มตรงนี้
        final total = tb + bestShoeScore + (t.isFavorite ? 1 : 0);

        entries.add((
          outfit: Outfit(top: t, bottom: b, shoes: bestShoe, score: total),
          tie: rnd.nextDouble(),
        ));
      }
    }

    entries.sort((a, b) {
      final c = b.outfit.score.compareTo(a.outfit.score);
      return c != 0 ? c : a.tie.compareTo(b.tie);
    });

    // เลือกแบบกระจาย: ชิ้นเดียวกันซ้ำได้ไม่เกิน _maxReuse ครั้งก่อน
    // ที่เหลือค่อยเติมท้ายถ้ายังไม่ครบ limit
    final picked = <Outfit>[];
    final skipped = <Outfit>[];
    final used = <String, int>{};

    for (final e in entries) {
      final o = e.outfit;
      final nTop = used[o.top.id] ?? 0;
      final nBottom = used[o.bottom.id] ?? 0;

      if (nTop < _maxReuse && nBottom < _maxReuse) {
        picked.add(o);
        used[o.top.id] = nTop + 1;
        used[o.bottom.id] = nBottom + 1;
      } else {
        skipped.add(o);
      }
    }

    return [...picked, ...skipped].take(limit).toList();
  }

  // ------------------------------------------------------------
  // Pairwise (หาชิ้นที่เข้ากับชิ้นเดียว เผื่อใช้ต่อยอด)
  // ------------------------------------------------------------

  /// คืนชิ้นที่เข้ากับ [base] จัดกลุ่มตาม category (เรียงคะแนนมาก -> น้อย)
  /// category เดียวกับ [base] จะไม่ถูกรวมอยู่ในผลลัพธ์
  Map<ItemCategory, List<ClothingItem>> recommendFor(
    ClothingItem base,
    List<ClothingItem> closet,
  ) {
    final result = <ItemCategory, List<ClothingItem>>{};

    for (final cat in ItemCategory.values) {
      if (cat == base.category) continue;

      final scored = <MapEntry<ClothingItem, int>>[];
      for (final item in closet) {
        if (item.id == base.id || item.category != cat) continue;
        final s = score(base, item);
        if (s > 0) scored.add(MapEntry(item, s));
      }

      scored.sort((a, b) => b.value.compareTo(a.value));
      result[cat] = scored.map((e) => e.key).toList();
    }
    return result;
  }

  // ------------------------------------------------------------
  // Scoring
  // ------------------------------------------------------------

  /// 0 = ไม่แนะนำ, ยิ่งมากยิ่งเข้ากัน
  int score(ClothingItem a, ClothingItem b) {
    // style ต่างกัน (casual vs formal) = ตัดทิ้ง
    // ถ้าอยากผ่อนปรน ให้เปลี่ยนเป็นหักคะแนนแทน เช่น c - 2
    if (a.style != b.style) return 0;

    final c = _colorScore(a.color, b.color);
    if (c == 0) return 0;

    // favorite ให้โบนัสเล็กน้อย
    return c + (b.isFavorite ? 1 : 0);
  }

  int _colorScore(ItemColor a, ItemColor b) {
    final ga = a.group, gb = b.group;

    // neutral เข้ากับทุกอย่าง
    if (ga == ColorGroup.neutral && gb == ColorGroup.neutral) return 4;
    if (ga == ColorGroup.neutral || gb == ColorGroup.neutral) return 5;

    // earth tone เข้ากับ earth และสีอื่นที่ไม่จัด
    if (ga == ColorGroup.earth && gb == ColorGroup.earth) return 4;
    if (ga == ColorGroup.earth || gb == ColorGroup.earth) {
      final other = ga == ColorGroup.earth ? b : a;
      return other.isBold ? 1 : 3;
    }

    // สีจัดชนสีจัด = ไม่แนะนำ
    if (a.isBold && b.isBold) return 0;

    // โทนเดียวกัน (warm+warm / cool+cool) ดี
    if (ga == gb) return 3;

    // warm + cool: ได้ถ้าไม่จัดทั้งคู่
    return 2;
  }
}