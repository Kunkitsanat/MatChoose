// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get recommend => 'แนะนำชุด';

  @override
  String get tryOutfit => 'ลองชุด';

  @override
  String get seeAll => 'ดูทั้งหมด';

  @override
  String get emptyCloset => 'ยังไม่มีเสื้อผ้าในตู้';

  @override
  String get emptyClosetHint => 'กดปุ่ม + เพื่อถ่ายรูปและเพิ่มชิ้นแรกของคุณ';

  @override
  String get addClothing => 'เพิ่มเสื้อผ้า';

  @override
  String get fromGallery => 'จากแกลเลอรี';

  @override
  String get takePhoto => 'ถ่ายรูป';
}
