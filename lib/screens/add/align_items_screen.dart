import 'package:flutter/material.dart';

class AlignItemsScreen extends StatefulWidget {
  const AlignItemsScreen({super.key});

  @override
  State<AlignItemsScreen> createState() => _AlignItemsScreenState();
}

class _AlignItemsScreenState extends State<AlignItemsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Align Items')),
      body: SafeArea(
        child: const Center(
          child: Text('Align Items')
        ),
        ),
    );
  }
}