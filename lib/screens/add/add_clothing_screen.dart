import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matchoose/screens/add/align_items_screen.dart';

class AddClothingScreen extends StatelessWidget {
  const AddClothingScreen({super.key});

  /// เลือกรูปจาก gallery แล้วส่งต่อไปหน้า Align (ปรับกรอบ/crop)
  /// เหมือน flow ของกล้อง — align_items_screen จะ crop+mask ให้เอง
  ///
  /// จำกัดขนาดตอนเลือกรูป (maxWidth/maxHeight) เพราะรูปจาก gallery
  /// มักมีความละเอียดสูงกว่ารูปจากกล้องในแอปนี้มาก (12MP+ ทั่วไป) การ
  /// decode/crop/encode ด้วย package `image` (pure Dart) กับรูปขนาดนั้น
  /// จะช้ามาก ย่อตั้งแต่ตอนเลือก (ทำฝั่ง native ให้ เร็วกว่าย่อทีหลังในโค้ดเรา)
  /// ช่วยให้ขั้นตอน crop/mask หลังจากนี้เร็วขึ้นมาก โดยยังคมพอสำหรับใช้ในแอป
  Future<void> pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 90,
    );

    if (image == null) return;
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlignItemsScreen(imagePath: image.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Add Clothing', style: TextStyle(fontSize: 24.0)),
              ],
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 120,
                      child: FilledButton(
                        onPressed: () => pickImage(context),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.brown.shade200,
                          foregroundColor: Colors.white,
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 32),
                            SizedBox(height: 8),
                            Text('From Gallery'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 150,
                      height: 120,
                      child: FilledButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AlignItemsScreen(),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.brown.shade200,
                          foregroundColor: Colors.white,
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo, size: 32),
                            SizedBox(height: 8),
                            Text('Take a Photo'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}