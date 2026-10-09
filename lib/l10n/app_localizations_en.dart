// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get recommend => 'Recommend';

  @override
  String get tryOutfit => 'Try Outfit';

  @override
  String get seeAll => 'See all';

  @override
  String get emptyCloset => 'Your closet is empty';

  @override
  String get emptyClosetHint => 'Tap + to take a photo and add your first item';

  @override
  String get saveOutfit => 'Save Outfit';

  @override
  String get outfitSaved => 'Outfit saved';

  @override
  String get outfitAlreadySaved => 'Outfit already saved';

  @override
  String get unableToRecommend => 'Unable to create an outfit';

  @override
  String get unableToRecommendHint =>
      'You need at least 1 top and 1 bottom with the same style and matching colors.';

  @override
  String get topsAndJackets => 'Tops & Jackets';

  @override
  String get bottoms => 'Bottoms';

  @override
  String get shoes => 'Shoes';

  @override
  String get casualWear => 'Casual Wear';

  @override
  String get formalWear => 'Formal Wear';

  @override
  String noItemsInCategory(String category) {
    return 'No $category yet';
  }

  @override
  String get addClothing => 'Add Clothing';

  @override
  String get fromGallery => 'From Gallery';

  @override
  String get takePhoto => 'Take a Photo';

  @override
  String get search => 'Search';

  @override
  String get name => 'NAME';

  @override
  String get searchByName => 'Search by name';

  @override
  String get category => 'CATEGORY';

  @override
  String get allCategories => 'All categories';

  @override
  String get color => 'COLOR';

  @override
  String get anyColor => 'Any Color';

  @override
  String get formality => 'FORMALITY';

  @override
  String get allStyles => 'All Styles';

  @override
  String get favoritesOnly => 'Favorites Only';

  @override
  String get searchResult => 'Search Results';

  @override
  String get noClothesFound => 'No clothes found';

  @override
  String get noClothesFoundHint => 'Try adjusting your search fliters.';

  @override
  String get item => 'item';

  @override
  String get items => 'items';

  @override
  String get found => 'found';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontSizeSystem => 'System default';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeNormal => 'Normal';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get fontSizeExtraLarge => 'Extra large';
}
