import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'add/add_clothing_screen.dart';
import 'search/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _pages = [HomeScreen(), AddClothingScreen(), SearchScreen()];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined, size: 30,),
            label: '',
          ),

          NavigationDestination(
            icon: Icon(Icons.add, size: 30,),
            label: '',
          ),

          NavigationDestination(
            icon: Icon(Icons.search, size:30,),
            label: '',
          ),
        ],
      ),
    );
  }
}