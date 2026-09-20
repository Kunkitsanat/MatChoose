import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // Variables
  // ============================================================

  // ตัวแปรของหน้าจอ


  // ============================================================
  // Init
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ทำงานครั้งเดียวตอนเปิดหน้า
  }

  // ============================================================
  // Functions
  // ============================================================

  // ฟังก์ชันต่าง ๆ ของหน้าจอ


  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    // ปิด controller / listener / resource ต่าง ๆ

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
        child: Column(
          children: [

            // Header
            Row(
              children: [
                const Text('Matchoose',style: TextStyle(fontSize: 32.0,),),
              ],
            ),

            const SizedBox(height: 20),

            // Recommend / Try Outfit
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                //Recommend
                FilledButton.icon(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.brown.shade200,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Recommend')
                ),

                const SizedBox(width: 10,),

                OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown.shade800
                  ),
                  icon: const Icon(Icons.checkroom),
                  label: const Text('Try Outfit'),
                )
              ]
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}