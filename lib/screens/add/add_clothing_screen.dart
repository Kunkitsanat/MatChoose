import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddClothingScreen extends StatelessWidget {
  const AddClothingScreen({super.key});

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      print(image.path);
    }
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
                const Text('Add Clothing',style: TextStyle(fontSize: 24.0,),),
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
                        onPressed: pickImage,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

                    SizedBox(width: 20,),

                    SizedBox(
                      width: 150,
                      height: 120,
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  ]
                ),
              ),
            )
          ]
        )
      )
    );
  }
}