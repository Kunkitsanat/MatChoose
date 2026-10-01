import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';

/// หน้า Try Outfit: เลือกเสื้อผ้า Tops & Jackets -> Bottoms -> Shoes
/// แต่ละแถวเลื่อนซ้าย-ขวาได้ กดที่รูปเพื่อไปหน้า Preview
/// วางที่ lib/screens/home/try_outfit_screen.dart
class TryOutfitScreen extends StatefulWidget {
  const TryOutfitScreen({super.key});

  @override
  State<TryOutfitScreen> createState() => _TryOutfitScreenState();
}

class _TryOutfitScreenState extends State<TryOutfitScreen> {
  // ============================================================
  // Variables
  // ============================================================

  final _closet = ClosetRepository.instance;

  /// ลำดับการแสดงผล (ยังไม่รวม shoes)
  static const _categories = [ItemCategory.tops, ItemCategory.bottoms];

  /// controller + index ปัจจุบันของแต่ละแถว
  final Map<ItemCategory, PageController> _controllers = {
    for (final c in _categories) c: PageController(),
  };
  final Map<ItemCategory, int> _index = {
    for (final c in _categories) c: 0,
  };

  // ============================================================
  // Init
  // ============================================================

  @override
  void initState() {
    super.initState();
    _closet.load();
  }

  // ============================================================
  // Functions
  // ============================================================

  List<ClothingItem> _itemsOf(List<ClothingItem> all, ItemCategory c) =>
      all.where((i) => i.category == c).toList();

  /// ชิ้นที่เลือกอยู่ในแต่ละหมวด (ข้ามหมวดที่ว่าง)
  List<ClothingItem> _selected(List<ClothingItem> all) {
    final result = <ClothingItem>[];
    for (final c in _categories) {
      final list = _itemsOf(all, c);
      if (list.isEmpty) continue;
      result.add(list[_index[c]!.clamp(0, list.length - 1)]);
    }
    return result;
  }

  void _saveOutfit(List<ClothingItem> all) {
    final outfit = _selected(all);
    if (outfit.isEmpty) return;

    // TODO: บันทึกชุดนี้ (เช่น OutfitRepository.add(outfit.map((e) => e.id)))
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Outfit saved')),
    );
  }

  void _openPreview(ClothingItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewItemScreen(item: item)),
    );
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ValueListenableBuilder<List<ClothingItem>>(
          valueListenable: _closet.items,
          builder: (context, all, _) {
            return Column(
              children: [
                _Header(onBack: () => Navigator.maybePop(context)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        children: [
                          for (final c in _categories)
                            Expanded(
                              child: _ItemRow(
                                category: c,
                                items: _itemsOf(all, c),
                                controller: _controllers[c]!,
                                onPageChanged: (i) => _index[c] = i,
                                onItemTap: _openPreview,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: FilledButton.icon(
                    onPressed: all.isEmpty ? null : () => _saveOutfit(all),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(180, 48),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.bookmark_border, size: 20),
                    label: const Text('Save Outfit'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// Widgets
// ============================================================

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onBack,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Icon(Icons.chevron_left, color: cs.onSurface),
                ),
              ),
            ),
            Text(
              'Try Outfit',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1 แถว: แสดงทีละชิ้น เลื่อนซ้าย-ขวาเลือกเสื้อผ้าในหมวดนั้น
class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.category,
    required this.items,
    required this.controller,
    required this.onPageChanged,
    required this.onItemTap,
  });

  final ItemCategory category;
  final List<ClothingItem> items;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<ClothingItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Center(
        child: Text(
          'ยังไม่มี ${category.label}',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return PageView.builder(
      controller: controller,
      itemCount: items.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, i) {
        final item = items[i];
        return GestureDetector(
          onTap: () => onItemTap(item),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.file(
              File(item.imagePath),
              fit: BoxFit.contain,
              cacheWidth: 1000, // ลดการใช้ memory
              errorBuilder: (_, __, ___) => Icon(
                Icons.broken_image_outlined,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}