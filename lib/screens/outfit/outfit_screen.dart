import 'package:flutter/material.dart';

class OutfitScreen extends StatelessWidget {
  const OutfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'My Outfits',
                  style: TextStyle(fontSize: 24.0),
                ),
              ],
            ),

            // เนื้อหาค่อยใส่ทีหลัง
          ],
        ),
      ),
    );
  }
}