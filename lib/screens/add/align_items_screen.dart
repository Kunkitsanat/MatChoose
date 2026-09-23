import 'package:flutter/material.dart';

/// หน้า "Align Outfit" - กล้องถ่ายเสื้อผ้าพร้อมกรอบ guide
///
/// ตอนนี้เป็น static layout เท่านั้น:
/// - ยังไม่ต่อกล้องจริง (ใช้กล่องสีทึบแทน)
/// - guide fix เป็น "tshirt" ตายตัว ยังไม่ต่อ overlay.png จริง
/// - ปุ่มต่างๆ ยังไม่มี logic กดแล้วทำงาน แค่วางตำแหน่งให้ถูกก่อน
class AlignItemsScreen extends StatelessWidget {
  const AlignItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A211C), // สีน้ำตาลเข้ม ตาม mockup
      body: SafeArea(
        child: Stack(
          children: [
            // ===== ชั้น 1: พื้นหลังกล้อง =====
            // TODO: แทนที่ด้วย CameraPreview จริงทีหลัง
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 70, 20, 100),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1512),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

            // ===== ชั้น 2: guide overlay ตรงกลาง (fix เป็น tshirt) =====
            Center(
              child: _GuideOverlayPlaceholder(),
            ),

            // ===== ชั้น 3: controls =====
            // top bar
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: _TopBar(),
            ),

            // shutter button (ล่างกลาง)
            Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: Center(child: _ShutterButton()),
            ),

            // elements button (ใต้ shutter)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(child: _ElementsButtonPlaceholder()),
            ),
          ],
        ),
      ),
    );
  }
}

/// กรอบ guide เส้นประ + โครงเสื้อ fix เป็น tshirt ไปก่อน
/// ทีหลังจะสลับเป็นโหลด assets/templates/tshirt/tshirt_overlay.png ตาม type ที่เลือก
class _GuideOverlayPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
          style: BorderStyle.solid, // Flutter ไม่มี dashed built-in, ใช้ solid ไปก่อน
        ),
      ),
      child: Center(
        child: Icon(
          Icons.checkroom_outlined,
          size: 100,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            // TODO: Navigator.pop(context)
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
        const Expanded(
          child: Text(
            'Align Outfit',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 48), // เผื่อพื้นที่ให้สมมาตรกับปุ่ม back
      ],
    );
  }
}

class _ShutterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: ถ่ายรูป + crop ตาม guide
      },
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
        ),
      ),
    );
  }
}

class _ElementsButtonPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFB99B7A), // สีน้ำตาลอ่อน ตาม mockup
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_outlined, size: 18, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Elements',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}