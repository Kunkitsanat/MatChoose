import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @recommend.
  ///
  /// In en, this message translates to:
  /// **'Recommend'**
  String get recommend;

  /// No description provided for @tryOutfit.
  ///
  /// In en, this message translates to:
  /// **'Try Outfit'**
  String get tryOutfit;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @emptyCloset.
  ///
  /// In en, this message translates to:
  /// **'Your closet is empty'**
  String get emptyCloset;

  /// No description provided for @emptyClosetHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to take a photo and add your first item'**
  String get emptyClosetHint;

  /// No description provided for @saveOutfit.
  ///
  /// In en, this message translates to:
  /// **'Save Outfit'**
  String get saveOutfit;

  /// No description provided for @outfitSaved.
  ///
  /// In en, this message translates to:
  /// **'Outfit saved'**
  String get outfitSaved;

  /// No description provided for @outfitAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Outfit already saved'**
  String get outfitAlreadySaved;

  /// No description provided for @unableToRecommend.
  ///
  /// In en, this message translates to:
  /// **'Unable to create an outfit'**
  String get unableToRecommend;

  /// No description provided for @unableToRecommendHint.
  ///
  /// In en, this message translates to:
  /// **'You need at least 1 top and 1 bottom with the same style and matching colors.'**
  String get unableToRecommendHint;

  /// No description provided for @topsAndJackets.
  ///
  /// In en, this message translates to:
  /// **'Tops & Jackets'**
  String get topsAndJackets;

  /// No description provided for @bottoms.
  ///
  /// In en, this message translates to:
  /// **'Bottoms'**
  String get bottoms;

  /// No description provided for @shoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get shoes;

  /// No description provided for @casualWear.
  ///
  /// In en, this message translates to:
  /// **'Casual Wear'**
  String get casualWear;

  /// No description provided for @formalWear.
  ///
  /// In en, this message translates to:
  /// **'Formal Wear'**
  String get formalWear;

  /// No description provided for @noItemsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No {category} yet'**
  String noItemsInCategory(String category);

  /// No description provided for @addClothing.
  ///
  /// In en, this message translates to:
  /// **'Add Clothing'**
  String get addClothing;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get fromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// No description provided for @alignOutfit.
  ///
  /// In en, this message translates to:
  /// **'Align Outfit'**
  String get alignOutfit;

  /// No description provided for @adjustPhoto.
  ///
  /// In en, this message translates to:
  /// **'Adjust Photo'**
  String get adjustPhoto;

  /// No description provided for @guideType.
  ///
  /// In en, this message translates to:
  /// **'GUIDE TYPE'**
  String get guideType;

  /// No description provided for @elements.
  ///
  /// In en, this message translates to:
  /// **'Elements'**
  String get elements;

  /// No description provided for @guideShirt.
  ///
  /// In en, this message translates to:
  /// **'Shirt'**
  String get guideShirt;

  /// No description provided for @guideTshirt.
  ///
  /// In en, this message translates to:
  /// **'T-Shirt'**
  String get guideTshirt;

  /// No description provided for @guidePants.
  ///
  /// In en, this message translates to:
  /// **'Pants'**
  String get guidePants;

  /// No description provided for @guideShorts.
  ///
  /// In en, this message translates to:
  /// **'Shorts'**
  String get guideShorts;

  /// No description provided for @imageProcessingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to process image. Please try again.'**
  String get imageProcessingFailed;

  /// No description provided for @photoCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to take photo. Please try again.'**
  String get photoCaptureFailed;

  /// No description provided for @saveItem.
  ///
  /// In en, this message translates to:
  /// **'Save Item'**
  String get saveItem;

  /// No description provided for @style.
  ///
  /// In en, this message translates to:
  /// **'STYLE'**
  String get style;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select color'**
  String get selectColor;

  /// No description provided for @selectStyle.
  ///
  /// In en, this message translates to:
  /// **'Select style'**
  String get selectStyle;

  /// No description provided for @addToCloset.
  ///
  /// In en, this message translates to:
  /// **'Add to Closet'**
  String get addToCloset;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @saveItemFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please try again.'**
  String get saveItemFailed;

  /// No description provided for @deleteCapturedPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'The captured photo will be deleted and cannot be recovered.'**
  String get deleteCapturedPhotoHint;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get name;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get category;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'COLOR'**
  String get color;

  /// No description provided for @anyColor.
  ///
  /// In en, this message translates to:
  /// **'Any Color'**
  String get anyColor;

  /// No description provided for @formality.
  ///
  /// In en, this message translates to:
  /// **'FORMALITY'**
  String get formality;

  /// No description provided for @allStyles.
  ///
  /// In en, this message translates to:
  /// **'All Styles'**
  String get allStyles;

  /// No description provided for @favoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites Only'**
  String get favoritesOnly;

  /// No description provided for @searchResult.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResult;

  /// No description provided for @noClothesFound.
  ///
  /// In en, this message translates to:
  /// **'No clothes found'**
  String get noClothesFound;

  /// No description provided for @noClothesFoundHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search filters.'**
  String get noClothesFoundHint;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'found'**
  String get found;

  /// No description provided for @previewItem.
  ///
  /// In en, this message translates to:
  /// **'Preview Item'**
  String get previewItem;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get deleteItem;

  /// No description provided for @deleteItemHint.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from your closet.'**
  String get deleteItemHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageThai.
  ///
  /// In en, this message translates to:
  /// **'Thai'**
  String get languageThai;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @fontSizeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get fontSizeSystem;

  /// No description provided for @fontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get fontSizeNormal;

  /// No description provided for @fontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// No description provided for @fontSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get fontSizeExtraLarge;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorGray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get colorGray;

  /// No description provided for @colorSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get colorSilver;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorBurgundy.
  ///
  /// In en, this message translates to:
  /// **'Burgundy'**
  String get colorBurgundy;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorCoral.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get colorCoral;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorPeach.
  ///
  /// In en, this message translates to:
  /// **'Peach'**
  String get colorPeach;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get colorGold;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorOlive.
  ///
  /// In en, this message translates to:
  /// **'Olive'**
  String get colorOlive;

  /// No description provided for @colorMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get colorMint;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorSkyBlue.
  ///
  /// In en, this message translates to:
  /// **'Sky Blue'**
  String get colorSkyBlue;

  /// No description provided for @colorNavy.
  ///
  /// In en, this message translates to:
  /// **'Navy'**
  String get colorNavy;

  /// No description provided for @colorRoyalBlue.
  ///
  /// In en, this message translates to:
  /// **'Royal Blue'**
  String get colorRoyalBlue;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get colorLavender;

  /// No description provided for @colorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorBrown;

  /// No description provided for @colorTan.
  ///
  /// In en, this message translates to:
  /// **'Tan'**
  String get colorTan;

  /// No description provided for @colorBeige.
  ///
  /// In en, this message translates to:
  /// **'Beige'**
  String get colorBeige;

  /// No description provided for @colorCream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get colorCream;

  /// No description provided for @colorKhaki.
  ///
  /// In en, this message translates to:
  /// **'Khaki'**
  String get colorKhaki;

  /// No description provided for @colorOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get colorOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
