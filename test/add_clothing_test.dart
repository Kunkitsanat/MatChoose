import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:matchoose/screens/add/add_clothing_screen.dart';
import 'package:matchoose/screens/main_screen.dart';
import 'package:matchoose/models/app_language.dart';

void main() {
  testWidgets('Go to Add Clothing Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: MainScreen(
          selectedLanguage: AppLanguage.system,
          onLanguageChanged: (value) {},
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add Clothing'), findsOneWidget);
  });

  testWidgets('Add Clothing Screen has a title and a button', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: AddClothingScreen()));

    // Verify that the title is displayed.
    expect(find.text('Add Clothing'), findsOneWidget);

    // Verify that the button is displayed.
    expect(find.byKey(const Key('from_gallery_button')), findsOneWidget);
    expect(find.byKey(const Key('take_photo_button')), findsOneWidget);
  });

  testWidgets('Pressing the button navigates to AlignItemsScreen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: AddClothingScreen()));

    // Tap the button.
    await tester.tap(find.byKey(const Key('take_photo_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that we navigated to the AlignItemsScreen.
    expect(find.text('Align Outfit'), findsOneWidget);
  });

}
