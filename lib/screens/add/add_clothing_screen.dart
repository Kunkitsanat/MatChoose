import 'package:flutter/material.dart';

class AddClothingScreen extends StatelessWidget {
  const AddClothingScreen({super.key});

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
          ]
        )
      )
    );
  }
}