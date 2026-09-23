import 'dart:io';

import 'package:flutter/material.dart';

import 'align_items_screen.dart' show GuideType;

/// tag ที่เลือกได้ในหน้านี้ (ตาม mockup: Casual / Formal)
enum ItemTag { casual, formal }

/// หน้า "Preview Item" - แสดงรูปที่ถ่าย+crop มาแล้ว ให้ user
/// ยืนยัน category/color/tag ก่อนบันทึกเข้าตู้เสื้อผ้า
///
/// ตอนนี้เป็น static-ish: มี UI ครบและกดเลือก tag ได้จริง
/// แต่ยังไม่มี logic save ข้อมูลจริง (รอคุยเรื่อง storage ก่อน)
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
  ItemTag? _selectedTag;

  /// เดา category เริ่มต้นจาก guide type ที่เลือกตอนถ่าย
  /// TODO: ให้ user แก้ไขเองได้ (เปลี่ยนเป็น dropdown/text field ทีหลัง)
  String get _defaultCategory {
    switch (widget.guideType) {
      case GuideType.shirt:
      case GuideType.tshirt:
        return 'Tops & Jackets';
      case GuideType.pants:
      case GuideType.short:
        return 'Bottoms';
    }
  }

  void _delete() {
    // TODO: ลบไฟล์รูป temp ทิ้ง (ถ้ายังไม่ได้ copy ไป documents dir)
    // pop กลับไปหน้ากล้องโดยไม่ส่งค่า save สำเร็จ (false)
    // เพื่อให้หน้ากล้องรู้ว่าไม่ต้องปิดตัวเองต่อ ถ่ายใหม่ได้เลย
    Navigator.of(context).pop(false);
  }

  void _save() {
    // TODO:
    // 1. copy widget.imagePath จาก temp -> app documents directory
    // 2. สร้าง ClothingItem แล้วบันทึกลง storage จริง (sqflite/hive/...)
    //
    // ตอนนี้แค่ pop กลับพร้อม true เพื่อให้ align_items_screen รู้ว่า
    // save สำเร็จแล้ว จะได้ pop ต่อกลับไปหน้า home เอง
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(
              onBack: () => Navigator.of(context).pop(),
              onSave: _save,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ItemImage(imagePath: widget.imagePath),
                    const SizedBox(height: 20),
                    _InfoRow(label: 'CATEGORY', value: _defaultCategory),
                    const SizedBox(height: 10),
                    // TODO: ดึงสีจริงจากรูป หรือให้ user เลือกเอง
                    const _InfoRow(label: 'COLOR', value: '—'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _TagChip(
                          label: 'Casual',
                          selected: _selectedTag == ItemTag.casual,
                          onTap: () => setState(() => _selectedTag =
                              _selectedTag == ItemTag.casual
                                  ? null
                                  : ItemTag.casual),
                        ),
                        const SizedBox(width: 8),
                        _TagChip(
                          label: 'Formal',
                          selected: _selectedTag == ItemTag.formal,
                          onTap: () => setState(() => _selectedTag =
                              _selectedTag == ItemTag.formal
                                  ? null
                                  : ItemTag.formal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFF8A847B),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, required this.onSave});

  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          const Expanded(
            child: Text(
              'Preview Item',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: onSave,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFFE6E1D8)),
            Image.file(File(imagePath), fit: BoxFit.contain),
            Positioned(
              top: 12,
              right: 12,
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: const Icon(
                  Icons.favorite_border,
                  size: 18,
                  color: Color(0xFF8A847B),
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
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              color: Color(0xFF8A847B),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A211C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF2A211C) : const Color(0xFFDDD6C9),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF4A443E),
          ),
        ),
      ),
    );
  }
}