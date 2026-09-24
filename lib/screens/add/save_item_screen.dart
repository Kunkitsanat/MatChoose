import 'dart:io';

import 'package:flutter/material.dart';

import 'align_items_screen.dart' show GuideType;
import 'closet_repository.dart';
import 'package:matchoose/models/clothing_item.dart';

// ============================================================
// Screen
// ============================================================

const _bg = Color(0xFFF7F5F0);
const _border = Color(0xFFEAE5DA);
const _muted = Color(0xFF8A847B);
const _ink = Color(0xFF2A211C);
const _accent = Color(0xFFC4B29C);
const _danger = Color(0xFFC0392B);

/// หน้า "Save Item" - แสดงรูปที่ถ่าย+crop มาแล้ว ให้ user เลือก
/// category / color / style ก่อนกด Add to Closet
///
/// pop กลับพร้อม `true` เมื่อบันทึกสำเร็จ, `false` เมื่อกดย้อนกลับ
/// (align_items_screen ใช้ค่านี้ตัดสินใจว่าจะปิดหน้ากล้องต่อหรือไม่)
class SaveItemScreen extends StatefulWidget {
  const SaveItemScreen({
    super.key,
    required this.imagePath,
    required this.guideType,
  });

  /// path ของรูป PNG โปร่งใสที่ crop มาจากหน้ากล้อง
  final String imagePath;

  /// guide type ที่เลือกไว้ตอนถ่าย ใช้เดา category เริ่มต้นให้
  final GuideType guideType;

  @override
  State<SaveItemScreen> createState() => _SaveItemScreenState();
}

class _SaveItemScreenState extends State<SaveItemScreen> {
  late ItemCategory _category = _categoryFor(widget.guideType);
  ItemColor? _color;
  ItemStyle? _style;
  bool _isFavorite = false;
  bool _saving = false;

  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  static ItemCategory _categoryFor(GuideType type) {
    switch (type) {
      case GuideType.shirt:
      case GuideType.tshirt:
        return ItemCategory.tops;
      case GuideType.pants:
      case GuideType.short:
        return ItemCategory.bottoms;
    }
  }

  /// ต้องเลือก color และ style ก่อนถึงจะบันทึกได้
  bool get _canSave => _color != null && _style != null;

  /// copy รูปเข้าตู้เสื้อผ้า + บันทึกข้อมูล แล้วปิดหน้านี้ (pop(true))
  /// หน้ากล้องจะปิดตัวเองต่อ และหน้า home อัปเดตเองผ่าน ClosetRepository.items
  Future<void> _save() async {
    if (!_canSave || _saving) return;

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await ClosetRepository.instance.add(
        tempImagePath: widget.imagePath,
        name: name,
        category: _category,
        color: _color!,
        style: _style!,
        isFavorite: _isFavorite,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Save item error: $e');

      if (!mounted) return;

      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกไม่สำเร็จ ลองอีกครั้ง'),
        ),
      );
    }
  }

  /// ถามยืนยันก่อนลบ แล้วลบไฟล์รูป temp และกลับไปหน้ากล้อง (ถ่ายใหม่ได้เลย)
  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete this item?'),
        content: const Text('รูปที่ถ่ายไว้จะถูกลบและไม่สามารถกู้คืนได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: _danger, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await File(widget.imagePath).delete();
    } catch (e) {
      debugPrint('Delete temp image failed: $e');
    }

    // pop(false) = ไม่ได้ save หน้ากล้องจึงไม่ปิดตัวเอง
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.of(context).pop(false)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ItemImage(
                      imagePath: widget.imagePath,
                      isFavorite: _isFavorite,
                      onToggleFavorite: () =>
                          setState(() => _isFavorite = !_isFavorite),
                    ),

                    const SizedBox(height: 28),

                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'NAME',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: _border),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _SelectField<ItemCategory>(
                      label: 'CATEGORY',
                      placeholder: 'Select category',
                      value: _category,
                      options: ItemCategory.values,
                      labelOf: (c) => c.label,
                      onChanged: (v) => setState(() => _category = v),
                    ),

                    const SizedBox(height: 20),

                    _SelectField<ItemColor>(
                      label: 'COLOR',
                      placeholder: 'Select color',
                      value: _color,
                      options: ItemColor.values,
                      labelOf: (c) => c.label,
                      leadingOf: (c) => _Swatch(color: c.swatch),
                      onChanged: (v) => setState(() => _color = v),
                    ),
                    
                    const SizedBox(height: 20),
                    _SelectField<ItemStyle>(
                      label: 'STYLE',
                      placeholder: 'Select style',
                      value: _style,
                      options: ItemStyle.values,
                      labelOf: (s) => s.label,
                      onChanged: (v) => setState(() => _style = v),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _canSave && !_saving ? _save : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              _accent.withValues(alpha: 0.5),
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Add to Closet'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ปุ่มลบ อยู่มุมขวาล่างของจอ
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(side: BorderSide(color: _border)),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _confirmDelete,
                      child: const SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          Icons.delete_outline,
                          color: _danger,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Save Item',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: _ink,
              fontFamily: 'Georgia',
              fontFamilyFallback: ['Times New Roman', 'serif'],
            ),
          ),
          Positioned(
            left: 16,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(side: BorderSide(color: _border)),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.arrow_back_ios_new, size: 14, color: _ink),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// การ์ดแสดงรูปเสื้อผ้า (PNG โปร่งใส) บนพื้นครีม
class _ItemImage extends StatelessWidget {
  const _ItemImage({
    required this.imagePath,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final String imagePath;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFFF1EEE3)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
              // ปุ่ม favorite (หัวใจ) มุมบนขวา
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onToggleFavorite,
                    child: SizedBox(
                      width: 38,
                      height: 38,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isFavorite),
                          size: 20,
                          color: isFavorite ? _danger : _muted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// วงกลมสี (other = วงกลมรุ้ง)
class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, this.size = 22});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        gradient: color == null
            ? const SweepGradient(colors: [
                Color(0xFFE53935),
                Color(0xFFFDD835),
                Color(0xFF43A047),
                Color(0xFF00ACC1),
                Color(0xFF3949AB),
                Color(0xFF8E24AA),
                Color(0xFFE53935),
              ])
            : null,
        // เส้นขอบบางๆ ให้เห็นสีขาว/ครีมบนพื้นสว่าง
        border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
      ),
    );
  }
}

/// ช่องเลือกหน้าตาแบบ dropdown ตาม mockup กดแล้วเปิด bottom sheet ให้เลือก
class _SelectField<T> extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.placeholder,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
    this.leadingOf,
  });

  final String label;
  final String placeholder;
  final T? value;
  final List<T> options;
  final String Function(T) labelOf;
  final Widget Function(T)? leadingOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final v = value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: _muted,
            ),
          ),
        ),
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _border),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onTap: () async {
              final picked = await _showPicker<T>(
                context,
                title: label[0] + label.substring(1).toLowerCase(),
                options: options,
                selected: v,
                labelOf: labelOf,
                leadingOf: leadingOf,
              );
              if (picked != null) onChanged(picked);
            },
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (v != null && leadingOf != null) ...[
                    leadingOf!(v),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      v != null ? labelOf(v) : placeholder,
                      style: TextStyle(
                        fontSize: 16,
                        color: v != null ? _ink : _muted,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: _muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<T?> _showPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T? selected,
  required String Function(T) labelOf,
  Widget Function(T)? leadingOf,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: _bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final maxH = MediaQuery.of(ctx).size.height * 0.7;

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: options.length,
                  itemBuilder: (_, i) {
                    final o = options[i];
                    final isSel = o == selected;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: isSel ? Colors.white : null,
                      leading: leadingOf?.call(o),
                      title: Text(
                        labelOf(o),
                        style: TextStyle(
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: _ink,
                        ),
                      ),
                      trailing:
                          isSel ? const Icon(Icons.check, color: _ink) : null,
                      onTap: () => Navigator.pop(ctx, o),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}