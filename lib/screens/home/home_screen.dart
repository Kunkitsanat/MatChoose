import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/models/clothing_item.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // Variables
  // ============================================================

  final _closet = ClosetRepository.instance;
  bool _loading = true;

  // ============================================================
  // Init
  // ============================================================

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ============================================================
  // Functions
  // ============================================================

  Future<void> _load() async {
    await _closet.load();
    if (mounted) setState(() => _loading = false);
  }

  /// แบ่งเสื้อผ้าตาม category (เรียงตามลำดับใน enum, ข้ามหมวดที่ว่าง)
  Map<ItemCategory, List<ClothingItem>> _groupByCategory(
    List<ClothingItem> items,
  ) {
    final groups = <ItemCategory, List<ClothingItem>>{};
    for (final c in ItemCategory.values) {
      final list = items.where((i) => i.category == c).toList();
      if (list.isNotEmpty) groups[c] = list;
    }
    return groups;
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    // ไม่มี controller/listener ที่ต้องปิด (ValueListenableBuilder จัดการเอง)
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Matchoose',
                        style: tt.headlineMedium?.copyWith(
                          fontSize: 32,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Recommend / Try Outfit
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // TODO: ไปหน้า Recommend
                          },
                          // สีมาจาก colorScheme.primary / onPrimary อัตโนมัติ
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(Icons.auto_awesome, size: 20),
                          label: const Text('Recommend'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: ไปหน้า Try Outfit
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: cs.surface,
                            foregroundColor: cs.onSurface,
                            minimumSize: const Size(0, 48),
                            shape: const StadiumBorder(),
                            side: BorderSide(color: cs.outlineVariant),
                          ),
                          icon: const Icon(Icons.checkroom, size: 20),
                          label: const Text('Try Outfit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // รายการเสื้อผ้าแบ่งตาม category
            Expanded(child: _buildCloset()),
          ],
        ),
      ),
    );
  }

  Widget _buildCloset() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<List<ClothingItem>>(
      valueListenable: _closet.items,
      builder: (context, items, _) {
        if (items.isEmpty) return const _EmptyCloset();

        final groups = _groupByCategory(items);

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            for (final entry in groups.entries)
              _CategorySection(
                title: entry.key.label,
                items: entry.value,
                onSeeAll: () {
                  // TODO: ไปหน้าดูทั้งหมดของหมวด entry.key
                },
                onItemTap: (item) {
                  // TODO: ไปหน้ารายละเอียดของ item
                },
              ),
          ],
        );
      },
    );
  }
}

// ============================================================
// Widgets
// ============================================================

/// 1 หมวด: หัวข้อ + See all + แถวรูปที่เลื่อนซ้าย-ขวาได้
class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.items,
    required this.onSeeAll,
    required this.onItemTap,
  });

  final String title;
  final List<ClothingItem> items;
  final VoidCallback onSeeAll;
  final ValueChanged<ClothingItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: tt.titleLarge?.copyWith(color: cs.onSurface),
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  'See all',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ListView แนวนอน เต็มความกว้างจอ (padding ข้างในแทน เพื่อให้รูปเลื่อนชนขอบจอ)
        SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, i) => _ItemCard(
              item: items[i],
              onTap: () => onItemTap(items[i]),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.onTap});

  final ClothingItem item;
  final VoidCallback onTap;

  static const double _width = 110;
  static const double _imageHeight = 130;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: _width,
                height: _imageHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: cs.surfaceContainerHigh),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.file(
                        File(item.imagePath),
                        fit: BoxFit.contain,
                        cacheWidth: 330, // ลดการใช้ memory ตอนแสดงรูป thumbnail
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.broken_image_outlined,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (item.isFavorite)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.surface.withValues(alpha: 0.9),
                          ),
                          child: Icon(
                            Icons.favorite,
                            size: 14,
                            color: cs.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodySmall?.copyWith(
                fontSize: 13,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCloset extends StatelessWidget {
  const _EmptyCloset();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checkroom_outlined, size: 56, color: cs.primary),
            const SizedBox(height: 12),
            Text(
              'ยังไม่มีเสื้อผ้าในตู้',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'กดปุ่ม + เพื่อถ่ายรูปและเพิ่มชิ้นแรกของคุณ',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}