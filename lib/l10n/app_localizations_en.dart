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
}
