import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/screens/add/closet_repository.dart';

/// หน้า Preview Item (view clothes) ตามดีไซน์ Figma "preview-clothes"
/// วางที่ lib/screens/home/preview_item_screen.dart
class PreviewItemScreen extends StatelessWidget {
  const PreviewItemScreen({super.key, required this.item});

  final ClothingItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final closet = ClosetRepository.instance;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        // ฟัง repository เพื่อให้หัวใจอัปเดตทันทีเมื่อกด favorite
        child: ValueListenableBuilder<List<ClothingItem>>(
          valueListenable: closet.items,
          builder: (context, items, _) {
            final current = items.firstWhere(
              (i) => i.id == item.id,
              orElse: () => item,
            );

            return Column(
              children: [
                _Header(onBack: () => Navigator.maybePop(context)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ImageCard(
                          item: current,
                          onToggleFavorite: () =>
                              closet.toggleFavorite(current.id),
                        ),
                        const SizedBox(height: 20),
                        _InfoRow(
                          label: 'Category',
                          child: Text(
                            current.category.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w500,
                              fontSize: 20
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          label: 'Color',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ColorDot(color: current.color),
                              const SizedBox(width: 8),
                              Text(
                                current.color.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _StyleChip(label: current.style.label),
                        const SizedBox(height: 24),
                        _DeleteButton(
                          onPressed: () => _confirmDelete(context, current),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ClothingItem current) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this item?'),
        content: const Text('It will be removed from your closet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await ClosetRepository.instance.delete(current.id);
    if (context.mounted) Navigator.pop(context);
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
              'Preview Item',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.item, required this.onToggleFavorite});

  final ClothingItem item;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: cs.surfaceContainerHigh),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Image.file(
                File(item.imagePath),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: InkWell(
                onTap: onToggleFavorite,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.surface.withValues(alpha: 0.9),
                  ),
                  child: Icon(
                    item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: item.isFavorite ? cs.error : cs.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 20
              ),
          ),
        ),
        child,
      ],
    );
  }
}

/// จุดสีของเสื้อผ้า (`other` ไม่มี swatch จึงแสดงเป็นวงกลมรุ้ง)
class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final ItemColor color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final swatch = color.swatch;

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: swatch,
        gradient: swatch == null
            ? const SweepGradient(colors: [
                Color(0xFFE53935),
                Color(0xFFFDD835),
                Color(0xFF43A047),
                Color(0xFF1E88E5),
                Color(0xFF8E24AA),
                Color(0xFFE53935),
              ])
            : null,
        border: Border.all(color: cs.outlineVariant),
      ),
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: tt.bodySmall?.copyWith(
          color: cs.onSurface,
          fontSize: 18
          ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Icon(Icons.delete_outline, size: 30, color: cs.onSurfaceVariant),
      ),
    );
  }
}