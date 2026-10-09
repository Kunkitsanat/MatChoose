import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';
import 'package:matchoose/services/recommendation_service.dart';

import 'package:matchoose/l10n/app_localizations.dart';

/// หน้า Recommend: แสดงชุดที่จับคู่มาให้ (เลื่อนซ้าย-ขวา, เสื้อ-กางเกง-รองเท้า เรียงแนวตั้ง)
class RecommendScreen extends StatefulWidget {
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  static const _service = RecommendationService();

  int _seed = DateTime.now().millisecondsSinceEpoch;

  // เพิ่ม PageController สำหรับเลื่อนซ้ายขวา
  // viewportFraction: 0.88 ทำให้เห็นขอบของการ์ดซ้ายขวานิดๆ
  final PageController _pageController = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
              onShuffle: () {
                setState(() => _seed++);
                // กลับไปหน้าแรกเมื่อกด Shuffle
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(0);
                }
              },
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

                  // เปลี่ยนจาก ListView เป็น PageView.builder
                  return PageView.builder(
                    controller: _pageController,
                    itemCount: outfits.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        // ใส่ padding ด้านข้างนิดหน่อยให้มีการเว้นระยะระหว่างการ์ด
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 16.0,
                        ),
                        child: _OutfitCard(
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
                  );
                },
              ),
            ),
            const SizedBox(height: 16), // เว้นระยะด้านล่าง
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
    final l10n = AppLocalizations.of(context)!;

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
              l10n.recommend,
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

/// การ์ด 1 ชุด: รูปเสื้อ / กางเกง / รองเท้า เรียงแนวตั้ง (Vertical Stack)
class _OutfitCard extends StatelessWidget {
  const _OutfitCard({required this.outfit, required this.onItemTap});

  final Outfit outfit;
  final ValueChanged<ClothingItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(32), // มนขึ้นอีกนิดให้เหมือน Card
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ป้ายบอก Style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              switch (outfit.style) {
                ItemStyle.casual => l10n.casualWear,
                ItemStyle.formal => l10n.formalWear,
              },
              style: tt.titleSmall?.copyWith(color: cs.primary),
            ),
          ),
          const SizedBox(height: 16),

          // เปลี่ยนจาก Row เป็น Column
          Expanded(child: _PieceTile(item: outfit.top, onTap: onItemTap)),
          const SizedBox(height: 12),
          Expanded(child: _PieceTile(item: outfit.bottom, onTap: onItemTap)),

          if (outfit.shoes != null) ...[
            const SizedBox(height: 12),
            Expanded(child: _PieceTile(item: outfit.shoes!, onTap: onItemTap)),
          ],
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

    // ถอด AspectRatio ออก ปล่อยให้มันขยายเต็มพื้นที่ Expanded ใน Column
    return GestureDetector(
      onTap: () => onTap(item),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColoredBox(
              color: cs.surfaceContainerHigh,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.file(
                  File(item.imagePath),
                  fit: BoxFit.contain, // ให้รูปพอดีกับกล่องโดยไม่โดนตัด
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image_outlined,
                    color: cs.onSurfaceVariant,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          if (item.isFavorite)
            Positioned(
              top: 12,
              right: 12,
              child: Icon(Icons.favorite, size: 20, color: cs.error),
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
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 56, color: cs.primary),
            const SizedBox(height: 12),
            Text(
              l10n.unableToRecommend,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.unableToRecommendHint,
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