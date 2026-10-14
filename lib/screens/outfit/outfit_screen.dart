import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:matchoose/l10n/app_localizations.dart';
import 'package:matchoose/models/clothing_item.dart';
import 'package:matchoose/models/outfit.dart';
import 'package:matchoose/screens/add/closet_repository.dart';
import 'package:matchoose/screens/home/outfit_repository.dart';
import 'package:matchoose/screens/home/preview_item_screen.dart';

/// หน้า My Outfits: แสดงชุดที่บันทึกไว้ (ใหม่สุดอยู่บน)
/// กดรูปเพื่อดูรายละเอียดชิ้นนั้น, เมนู ⋮ เพื่อเปลี่ยนชื่อ/ลบชุด
/// วางที่ lib/screens/outfit/outfit_screen.dart
class OutfitScreen extends StatefulWidget {
  const OutfitScreen({super.key});

  @override
  State<OutfitScreen> createState() => _OutfitScreenState();
}

enum _OutfitAction { rename, delete }

class _OutfitScreenState extends State<OutfitScreen> {
  final _outfitRepo = OutfitRepository.instance;
  final _closet = ClosetRepository.instance;

  @override
  void initState() {
    super.initState();
    _outfitRepo.load();
    _closet.load();
  }

  // ============================================================
  // Functions
  // ============================================================

  void _openPreview(ClothingItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewItemScreen(item: item)),
    );
  }

  Future<void> _rename(Outfit outfit) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: outfit.name),
    );

    if (name == null || name.trim().isEmpty || name.trim() == outfit.name) {
      return;
    }
    await _outfitRepo.rename(outfit.id, name.trim());
  }

  Future<void> _confirmDelete(Outfit outfit) async {
    final l10n = AppLocalizations.of(context)!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteOutfit),
        content: Text(l10n.deleteOutfitHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (ok == true) await _outfitRepo.delete(outfit.id);
  }

  void _onAction(_OutfitAction action, Outfit outfit) {
    switch (action) {
      case _OutfitAction.rename:
        _rename(outfit);
      case _OutfitAction.delete:
        _confirmDelete(outfit);
    }
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Column(
          children: [
            Text(
              l10n.myOutfits,
              style: tt.headlineSmall?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 16),
            Expanded(
              // ฟังทั้งรายการชุด และตู้เสื้อผ้า (เผื่อมีชิ้นถูกลบ/แก้ไข)
              child: ListenableBuilder(
                listenable: Listenable.merge([_outfitRepo.outfits, _closet.items]),
                builder: (context, _) {
                  final outfits = _outfitRepo.outfits.value;

                  if (outfits.isEmpty) return const _EmptyState();

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: outfits.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.5, // การ์ดสูง เพื่อเรียงชิ้นแนวตั้ง
                    ),
                    itemBuilder: (context, i) {
                      final outfit = outfits[i];
                      return _OutfitCard(
                        outfit: outfit,
                        items: _outfitRepo.itemsOf(outfit),
                        onItemTap: _openPreview,
                        onAction: (a) => _onAction(a, outfit),
                      );
                    },
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

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({
    required this.outfit,
    required this.items,
    required this.onItemTap,
    required this.onAction,
  });

  final Outfit outfit;
  final List<ClothingItem> items;
  final ValueChanged<ClothingItem> onItemTap;
  final ValueChanged<_OutfitAction> onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMd(locale).format(outfit.createdAt);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 0, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfit.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      date,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_OutfitAction>(
                icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                onSelected: onAction,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _OutfitAction.rename,
                    child: Text(l10n.rename),
                  ),
                  PopupMenuItem(
                    value: _OutfitAction.delete,
                    child: Text(l10n.delete),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        l10n.outfitItemsMissing,
                        textAlign: TextAlign.center,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: _Thumb(
                                item: items[i],
                                onTap: () => onItemTap(items[i]),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item, required this.onTap});

  final ClothingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ColoredBox(
          color: cs.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.file(
              File(item.imagePath),
              fit: BoxFit.contain,
              cacheWidth: 400, // ลดการใช้ memory
              errorBuilder: (_, __, ___) => Icon(
                Icons.broken_image_outlined,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
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
            Icon(Icons.bookmark_border, size: 56, color: cs.primary),
            const SizedBox(height: 12),
            Text(
              l10n.noOutfits,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.noOutfitsHint,
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

/// Dialog เปลี่ยนชื่อชุด (แยกเป็น StatefulWidget เพื่อ dispose controller ให้ถูกต้อง)
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.rename),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textInputAction: TextInputAction.done,
        onSubmitted: (v) => Navigator.pop(context, v),
        decoration: InputDecoration(hintText: l10n.outfitName),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}