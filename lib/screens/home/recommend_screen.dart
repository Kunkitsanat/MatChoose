import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';
import 'package:matchoose/services/recommendation_service.dart';

/// หน้า Recommend: แสดงชุดที่จับคู่มาให้ (เสื้อ + กางเกง + รองเท้า)
/// วางที่ lib/screens/home/recommend_screen.dart
class RecommendScreen extends StatefulWidget {
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  static const _service = RecommendationService();

  /// เปลี่ยน seed = สลับลำดับชุดที่คะแนนเท่ากัน (ปุ่ม shuffle)
  /// ใช้ seed แทน Random() ตรงๆ เพื่อไม่ให้ชุดเปลี่ยนเองทุกครั้งที่ rebuild
  int _seed = DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onBack: () => Navigator.maybePop(context),
              onShuffle: () => setState(() => _seed++),
            ),
            Expanded(
              child: ValueListenableBuilder<List<ClothingItem>>(
                valueListenable: ClosetRepository.instance.items,
                builder: (context, items, _) {
                  final outfits = _service.recommendOutfits(
                    items,
                    random: Random(_seed),
                  );

                  if (outfits.isEmpty) return const _EmptyState();

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: outfits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => _OutfitCard(
                      outfit: outfits[i],
                      onItemTap: (item) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PreviewItemScreen(item: item),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widgets
// ============================================================

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onShuffle});

  final VoidCallback onBack;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget circleButton(IconData icon, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Icon(icon, size: 20, color: cs.onSurface),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: circleButton(Icons.chevron_left, onBack),
            ),
            Text(
              'Recommend',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: circleButton(Icons.shuffle, onShuffle),
            ),
          ],
        ),
      ),
    );
  }
}

/// การ์ด 1 ชุด: รูปเสื้อ / กางเกง / รองเท้า เรียงแนวนอน
class _OutfitCard extends StatelessWidget {
  const _OutfitCard({required this.outfit, required this.onItemTap});

  final Outfit outfit;
  final ValueChanged<ClothingItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              outfit.style.label,
              style: tt.bodySmall?.copyWith(color: cs.onSurface),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PieceTile(item: outfit.top, onTap: onItemTap)),
              const SizedBox(width: 10),
              Expanded(
                child: _PieceTile(item: outfit.bottom, onTap: onItemTap),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: outfit.shoes == null
                    ? const SizedBox.shrink()
                    : _PieceTile(item: outfit.shoes!, onTap: onItemTap),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PieceTile extends StatelessWidget {
  const _PieceTile({required this.item, required this.onTap});

  final ClothingItem item;
  final ValueChanged<ClothingItem> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => onTap(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: cs.surfaceContainerHigh),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.file(
                      File(item.imagePath),
                      fit: BoxFit.contain,
                      cacheWidth: 330,
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
                      child: Icon(Icons.favorite, size: 14, color: cs.error),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall?.copyWith(fontSize: 12, color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            Icon(Icons.auto_awesome_outlined, size: 56, color: cs.primary),
            const SizedBox(height: 12),
            Text(
              'ยังจับคู่ชุดไม่ได้',
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ต้องมีเสื้อและกางเกงที่ style เดียวกัน และสีเข้ากัน '
              'อย่างน้อยอย่างละ 1 ชิ้น',
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