import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'add/add_clothing_screen.dart';
import 'search/search_screen.dart';
import 'outfit/outfit_screen.dart';
import 'setting/setting_screen.dart';
import 'package:matchoose/models/app_language.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeScreen(),
      OutfitScreen(),
      AddClothingScreen(),
      SearchScreen(),
      SettingsScreen(
        selectedLanguage: widget.selectedLanguage,
        onLanguageChanged: widget.onLanguageChanged,
      ),
    ];

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
            icon: Icon(Icons.bookmark_border, size: 30),
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

          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: 30),
            label: '',
          ),

        ],
      ),
    );
  }
}